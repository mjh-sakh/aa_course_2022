# frozen_string_literal: true

module TaskSchemas

  def TaskCreated_v1
    t :message_name, 'TaskCreated'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskAssigned_v1
    t :message_name, 'TaskAssigned'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskCompleted_v1
    t :message_name, 'TaskCompleted'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :completed_by_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskUpdated_v1
    t :message_name, 'TaskUpdated'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :status, String
    t :timestamp, optional(Time)
  end

  # ---- V2 -----

  def TaskCreated_v2
    check_meta_data 2, 'task_service', 'TaskCreated'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskAssigned_v2
    check_meta_data 2, 'task_service', 'TaskAssigned'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskCompleted_v2
    check_meta_data 2, 'task_service', 'TaskCompleted'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :completed_by_id, method(:uuid?)
    t :timestamp, Time
  end

  def TaskUpdated_v2
    check_meta_data 2, 'task_service', 'TaskUpdated'
    @subject = t :data, Hash
    t :task_id, method(:uuid?)
    t :jira_id, optional(String)
    t :description, String
    t :assignee_id, method(:uuid?)
    t :status, String
    t :timestamp, optional(Time)
  end

end