# frozen_string_literal: true

class Accounts::RegistrationsController < Devise::RegistrationsController
  # 'aa' stands for 'Async Architecture' course name
  ACCOUNTS_TOPIC_CUD = 'aa_accounts_stream'

  def create
    super

    # ----------------------------- produce event -----------------------
    message = {
      # event_id: SecureRandom.uuid,
      # event_version: 1,
      # event_time: Time.now.to_s,
      # producer: 'auth_service',
      message_name: 'AccountCreated',
      data: {
        id: resource.id,
        email: resource.email,
        full_name: resource.full_name,
        position: resource.position,
        role: resource.role
      }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------
  end

  def sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name])
    super
  end
end
