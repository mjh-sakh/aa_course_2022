class TaskUpserter
  def initialize(message)
    @event_name = message['event_name']
    @data = message['data']
    @logger = ActiveSupport::Logger.new(STDOUT)
  end

  def upsert!
    case @event_name
    when 'TaskUpdated'
      update_task!
    else
      @logger.info "Ignoring '#{@event_name}' message."
    end
  end

  def update_task!
    ActiveRecord::Base.transaction do
      task = Task.find_by(task_idx: @data['task_public_id'])
      user = User.find_or_create_by!(user_idx: @data['assignee_public_id'])
      task_data = {
        task_idx: @data['task_public_id'],
        jira_id: @data['jira_id'],
        description: @data['description'],
        user_id: user.id,
        status: @data['status']
      }
      if task.nil?
        @logger.info "Task '#{@data[:description]}' is new but updated; task will be created."
        Task.create!(**task_data)
      else
        task.update!(**task_data)
        @logger.info "Task '#{task.description}' updated."
      end
    end
  end
end
