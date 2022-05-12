class AccountsController < ApplicationController
  ACCOUNTS_TOPIC = 'aa_accounts_stream'
  
  before_action :set_account, only: [:show, :edit, :update, :destroy, :enable]

  before_action :authenticate_account!, only: [:index]

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.order(:created_at).all
  end

  # GET /accounts/current.json
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
          # **account_event_data,
          type: 'AccountUpdated',
          data: {
            id: @account.id,
            email: @account.email,
            full_name: @account.full_name,
            position: @account.position,
            role: @account.role
          }
        }
        Producer.new.publish(message, topic: ACCOUNTS_TOPIC)
        # --------------------------------------------------------------------

        produce_business_event(@account.id, new_role) if new_role

        # --------------------------------------------------------------------

        format.html { redirect_to root_path, notice: 'Account was successfully updated.' }
        format.json { render :index, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
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
      # **account_event_data,
      type: 'AccountDeleted',
      data: { id: @account.id }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC)
    # --------------------------------------------------------------------

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT
  def enable
    @account.update(active: true, disabled_at: nil)

    # ----------------------------- produce event -----------------------
    message = {
      # **account_event_data,
      type: 'AccountEnabled',
      data: { id: @account.id }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC)
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

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def account_params
    params.require(:account).permit(:full_name, :role)
  end

  def produce_business_event(id, role)
    message = {
      # **account_event_data,
      type: 'AccountRoleChanged',
      data: { id: id, role: role }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC)
    # end
  end
end
