# frozen_string_literal: true

module TaskSchemas

  def TaskCreated_v1
    t :event_name, 'TaskCreated'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :assignee_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskAssigned_v1
    t :event_name, 'TaskAssigned'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :assignee_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskCompleted_v1
    t :event_name, 'TaskCompleted'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :description, String
    t :assignee_public_id, method(:uuid?)
    t :completed_by_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskUpdated_v1
    t :event_name, 'TaskUpdated'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :description, String
    t :assignee_public_id, method(:uuid?)
    t :status, String
    t :timestamp, optional(Time)
  end

  # ---- V2 -----

  def TaskCreated_v2
    t :message_version, 2
    t :event_name, 'TaskCreated'
    t :message_time, Time
    t :producer, 'task_service'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :assignee_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskAssigned_v2
    t :message_version, 2
    t :event_name, 'TaskAssigned'
    t :message_time, Time
    t :producer, 'task_service'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :assignee_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskCompleted_v2
    t :message_version, 2
    t :event_name, 'TaskCompleted'
    t :message_time, Time
    t :producer, 'task_service'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :assignee_public_id, method(:uuid?)
    t :completed_by_public_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskUpdated_v2
    t :message_version, 2
    t :event_name, 'TaskUpdated'
    t :message_time, Time
    t :producer, 'task_service'
    @subject = t :data, Hash
    t :task_public_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_public_id, method(:uuid?)
    t :status, String
    t :timestamp, optional(Time)
  end

end