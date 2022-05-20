# frozen_string_literal: true

module AuthSchemas

  def AccountCreated_v1
    t :event_name, 'AccountCreated'
    @subject = t :data, Hash
    t :id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountUpdated_v1
    t :event_name, 'AccountUpdated'
    @subject = t :data, Hash
    t :id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountDeleted_v1
    t :event_name, 'AccountDeleted'
    @subject = t :data, Hash
    t :id, method(:uuid?)
  end

  # --- V2 ----

  def AccountCreated_v2
    t :message_version, 2
    t :event_name, 'AccountCreated'
    t :message_time, Time
    t :producer, 'auth_service'
    @subject = t :data, Hash
    t :account_public_id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountUpdated_v2
    t :message_version, 2
    t :event_name, 'AccountUpdated'
    t :message_time, Time
    t :producer, 'auth_service'
    @subject = t :data, Hash
    t :account_public_id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountDeleted_v2
    t :message_version, 2
    t :event_name, 'AccountDeleted'
    t :message_time, Time
    t :producer, 'auth_service'
    @subject = t :data, Hash
    t :account_public_id, method(:uuid?)
  end
end
