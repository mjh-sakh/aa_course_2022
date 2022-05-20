class AccountsController < ApplicationController
  ACCOUNTS_TOPIC_CUD = 'aa_accounts_stream'
  ACCOUNTS_TOPIC_BE = 'aa_accounts_lifecycle'

  before_action :set_account, only: [:edit, :update, :destroy, :enable]

  before_action :authenticate_account!, except: [:current]

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.order(:created_at).all
  end

  # GET /accounts/current.json
  # used by other services to get data per the strategy
  def current
    render json: current_account.to_json
  end

  # GET /accounts/1/edit
  def edit
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      new_role = @account.role != account_params[:role] ? account_params[:role] : nil

      if @account.update(account_params)
        # ----------------------------- produce event -----------------------
        message = {
          event_name: 'AccountUpdated',
          message_version: 2,
          message_time: Time.now,
          producer: 'auth_service',
          data: {
            id: @account.id,  # left for forward compatibility
            account_public_id: @account.id,
            email: @account.email,
            full_name: @account.full_name,
            position: @account.position,
            role: @account.role
          }
        }

        # TODO: remove forward compatibility when v1 is not in use
        SchemaValidator.new(message, :AccountUpdated_v1).validate! # for Accounting
        SchemaValidator.new(message, :AccountUpdated_v2).validate! # for Tasks
        Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
        # --------------------------------------------------------------------

        produce_business_event(@account.id, new_role) if new_role

        # --------------------------------------------------------------------

        redirect_to root_path, notice: 'Account was successfully updated.'
      else
        render :edit
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  # in DELETE action, CUD event
  def destroy
    @account.update(active: false, disabled_at: Time.now)

    # ----------------------------- produce event -----------------------
    message = {
      type: 'AccountDeleted',
      data: { id: @account.id }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------

    respond_to do |format|
      redirect_to root_path, notice: 'Account was successfully destroyed.'
    end
  end

  # PUT
  # for education purposes only to play with accounts and messages
  def enable
    @account.update(active: true, disabled_at: nil)

    # ----------------------------- produce event -----------------------
    message = {
      type: 'AccountEnabled',
      data: { id: @account.id }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------

    respond_to do |format|
      redirect_to root_path, notice: 'Account was successfully enabled.'
    end
  end

  def resend_all_active_accounts
    count = 0
    Account.where(active: true).each do |account|
      message = {
        event_name: 'AccountUpdated',
        message_version: 2,
        message_time: Time.now,
        producer: 'auth_service',
        data: {
          id: account.id,  # left for forward compatibility
          account_public_id: account.id,
          email: account.email,
          full_name: account.full_name,
          position: account.position,
          role: account.role
        }
      }

      # TODO: remove forward compatibility when v1 is not in use
      SchemaValidator.new(message, :AccountUpdated_v1).validate! # for Accounting
      SchemaValidator.new(message, :AccountUpdated_v2).validate! # for Tasks
      Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
      count += 1
    end

    redirect_to root_path, notice: "Information about #{count} active accounts was resent."
  end

  private

  def current_account
    if doorkeeper_token
      Account.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:full_name, :role)
  end

  def produce_business_event(id, role)
    message = {
      type: 'AccountRoleChanged',
      data: { id: id, role: role }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_BE)
  end
end
