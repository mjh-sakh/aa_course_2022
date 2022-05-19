# frozen_string_literal: true

module AuthSchemas

  def AccountCreated_v1
    t :message_name, 'AccountCreated'
    @subject = t :data, Hash
    t :id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountUpdated_v1
    t :message_name, 'AccountUpdated'
    @subject = t :data, Hash
    t :id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountDeleted_v1
    t :message_name, 'AccountDeleted'
    @subject = t :data, Hash
    t :id, method(:uuid?)
  end

  # --- V2 ----

  def AccountCreated_v2
    check_meta_data 2, 'auth_service', 'AccountCreated'
    @subject = t :data, Hash
    t :account_id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountUpdated_v2
    check_meta_data 2, 'auth_service', 'AccountUpdated'
    @subject = t :data, Hash
    t :account_id, method(:uuid?)
    t :email, String
    t :full_name, optional(String)
    t :position, optional(String)
    t :role, String
  end

  def AccountDeleted_v2
    check_meta_data 2, 'auth_service', 'AccountDeleted'
    @subject = t :data, Hash
    t :account_id, method(:uuid?)
  end
end
