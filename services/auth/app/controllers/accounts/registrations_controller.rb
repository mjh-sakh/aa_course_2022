# frozen_string_literal: true

class Accounts::RegistrationsController < Devise::RegistrationsController
  # 'aa' stands for 'Async Architecture' course name
  ACCOUNTS_TOPIC_CUD = 'aa_accounts_stream'

  def create
    super

    # ----------------------------- produce event -----------------------
    message = {
      event_name: 'AccountCreated',
      message_version: 2,
      message_time: Time.now,
      producer: 'auth_service',
      data: {
        id: resource.id,  # left for forward compatibility
        account_public_id: resource.id,
        email: resource.email,
        full_name: resource.full_name,
        position: resource.position,
        role: resource.role
      }
    }

    # TODO: remove forward compatibility when v1 is not in use
    SchemaValidator.new(message, :AccountUpdated_v1).validate! # for Accounting
    SchemaValidator.new(message, :AccountCreated_v2).validate! # for Tasks
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------
  end

  def sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name])
    super
  end
end
