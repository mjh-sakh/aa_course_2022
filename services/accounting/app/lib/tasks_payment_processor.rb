# frozen_string_literal: true

class TasksPaymentProcessor
  COST_RANGE = 10..20
  REWARD_RANGE = 20..40

  def initialize(message)
    @message_name = message['message_name']
    @data = message['data']
    @logger = ActiveSupport::Logger.new(STDOUT)
  end

  def process!
    case @message_name
    when 'TaskCreated'
      ActiveRecord::Base.transaction do
        create_task!
        bill_worker!
      end
    when 'TaskAssigned'
      bill_worker!
    when 'TaskCompleted'
      ActiveRecord::Base.transaction do
        complete_task!
        reward_worker!
      end
    else
      @logger.info "Ignoring '#{@message_name}' message."
    end
  end

  def create_task!
    # if TaskCreated come after other events
    return unless Task.find_by(task_idx: @data['task_id']).nil?

    worker = User.find_or_create_by(user_idx: @data['assignee_id'])
    task = Task.new(
      task_idx: @data['task_id'],
      jira_id: @data['jira_id'],
      description: @data['description'],
      user_id: worker.id,
      status: :open
    )

    ActiveRecord::Base.transaction do
      task.save!
      rate_task! task.id
    end

    task
  end

  def rate_task!(id)
    task = Task.find(id)
    task.update(
      cost: rand(COST_RANGE),
      reward: rand(REWARD_RANGE)
    )
    task
  end

  def bill_worker!
    ActiveRecord::Base.transaction do
      task = Task.find_or_create_by!(task_idx: @data['task_id'])
      task = rate_task!(task.id) if task.cost.nil?
      worker = User.find_or_create_by(user_idx: @data['assignee_id'])
      TransactionLogRecord.create!(
        user_id: worker.id,
        event_time: Time.parse(@data['timestamp']),
        record_time: Time.now.utc,
        amount: -task.cost, # negative
        record_type: :billing,
        reference_id: task.id,
        note: 'bill worker as task got assigned'
      )
      worker.balance -= task.cost
      worker.balance_update_time = Time.now.utc
      worker.save!
    end
  end

  def complete_task!
    task = Task.find_or_create_by!(task_idx: @data['task_id'])
    task.update!(
      status: :complete,
      completed_at: @data['timestamp']
    )
  end

  def reward_worker!
    ActiveRecord::Base.transaction do
      task = Task.find_by(task_idx: @data['task_id'])
      task = rate_task!(task.id) if task.reward.nil?
      worker = User.find_or_create_by(user_idx: @data['assignee_id'])
      TransactionLogRecord.create!(
        user_id: worker.id,
        event_time: Time.parse(@data['timestamp']),
        record_time: Time.now.utc,
        amount: task.reward,
        record_type: :reward,
        reference_id: task.id,
        note: 'reward worker for completed task'
      )
      worker.balance += task.reward
      worker.balance_update_time = Time.now.utc
      worker.save!
    end
  end
end
