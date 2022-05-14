class UserUpserter
  # typical message structure from Auth service
  # {
  #   event_name: 'AccountCreated',
  #   data: {
  #     id: account.id,
  #     email: account.email,
  #     full_name: account.full_name,
  #     position: account.position,
  #     role: account.role
  #   }
  # }
  def initialize(message)
    @message_name = message['message_name']
    @data = message['data']
    @logger = ActiveSupport::Logger.new(STDOUT)
  end

  def upsert!
    case @message_name
    when 'AccountCreated'
      create_user!
    when 'AccountUpdated'
      update_user!
    when 'AccountDeleted'
      deactivate_user!
    when 'AccountEnabled'
      activate_user!
    else
      @logger.info "Ignoring '#{@message_name}' message."
    end
  end

  def create_user!
    user = User.new(
      user_idx: @data[:id],
      name: @data[:full_name],
      status: :active
    )

    ActiveRecord::Base.transaction do
      role.save!
      user.roles << role
      user.save!
    end
    @logger.info "User #{user.name} created."
  end

  def update_user!
    user = User.find_by(user_idx: @data[:id])

    if user.nil?
      @logger.info "User #{@data[:full_name]} is new but updated; user will be created."
      create_user!
    elsif user.active?
      ActiveRecord::Base.transaction do
        role.save!
        user.name = @data[:full_name]
        user.roles = []
        user.roles << role
        user.save
      end
      @logger.info "User #{user.name} updated."
    else
      @logger.info "Ignoring '#{@message_name}' message for user #{user.name} as not active."
    end
  end

  def deactivate_user!
    user = User.find_by(user_idx: @data[:id])
    if user.nil?
      @logger.info "User with id: #{@data[:id]} is not found; Ignored."
    else
      ActiveRecord::Base.transaction do
        user.status = :deactivated
        user.roles = []
        user.save!
      end
      @logger.info "User #{user.name} deactivated."
    end
  end

  def activate_user!
    user = User.find_by(user_idx: @data[:id])
    if user.nil?
      @logger.info "User with id: #{@data[:id]} is not found; Ignored."
    else
      user.update(status: :active)
      @logger.info "User #{user.name} activated."
    end
  end

  def role
    @role ||= Role.find_by(name: @data[:role]) || Role.new(name: @data[:role])
  end
end
