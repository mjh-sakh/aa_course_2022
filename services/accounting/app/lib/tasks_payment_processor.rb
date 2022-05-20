# frozen_string_literal: true

class TasksPaymentProcessor

  def initialize(message)
    @event_name = message['event_name']
    @data = message['data']
    @logger = ActiveSupport::Logger.new(STDOUT)
  end

  def process!
    case @event_name
    when 'TaskCreated'
      bill_worker!
    when 'TaskAssigned'
      bill_worker!
    when 'TaskCompleted'
      reward_worker!
    else
      @logger.info "Ignoring '#{@event_name}' message."
    end
  end

  def bill_worker!
    ActiveRecord::Base.transaction do
      task = Task.find_or_create_by!(task_idx: @data['task_public_id'])
      worker = User.find_or_create_by(user_idx: @data['assignee_public_id'])
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
      worker.save!
    end
  end

  def reward_worker!
    ActiveRecord::Base.transaction do
      task = Task.find_by(task_idx: @data['task_public_id'])
      worker = User.find_or_create_by(user_idx: @data['assignee_public_id'])
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
      worker.save!
    end
  end
end
