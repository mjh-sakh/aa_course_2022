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
          message_name: 'AccountUpdated',
          data: {
            id: @account.id,
            email: @account.email,
            full_name: @account.full_name,
            position: @account.position,
            role: @account.role
          }
        }
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
      format.html { redirect_to root_path, notice: 'Account was successfully enabled.' }
      format.json { head :no_content }
    end
  end

  private

  # save it for future, not in use for week 1
  def account_event_data
    {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'aa_auth_service',
    }
  end

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
