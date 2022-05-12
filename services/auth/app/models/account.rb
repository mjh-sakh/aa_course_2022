class Account < ApplicationRecord
  ACCOUNTS_TOPIC = 'aa_accounts_stream'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  enum role: {
    admin: 'admin',
    worker: 'worker',
    manager: 'manager'
  }

  after_commit do
    self.reload
    account = self

    if account.created_at > Time.now - 5.seconds # filtering updates
      # ----------------------------- produce event -----------------------
      message = {
        # event_id: SecureRandom.uuid,
        # event_version: 1,
        # event_time: Time.now.to_s,
        # producer: 'auth_service',
        type: 'AccountCreated',
        data: {
          id: account.id,
          email: account.email,
          full_name: account.full_name,
          position: account.position,
          role: account.role
        }
      }
      # result = SchemaRegistry.validate_event(event, 'accounts.created', version: 1)
      # if result.success?
      Producer.new.publish(message, topic: ACCOUNTS_TOPIC)
      # end
      # --------------------------------------------------------------------
    end
  end
end
