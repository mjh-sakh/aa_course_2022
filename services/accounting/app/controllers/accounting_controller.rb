# frozen_string_literal: true

class AccountingController < ApplicationController

  before_action :authenticate_user!, except: :login
  before_action do
    if current_user
      current_user_roles
      current_user_permissions
    end
  end

  def login; end

  def index
    if @current_user_permissions.include? 'view_worker_stats'
      @records = TransactionLogRecord.includes(:task)
                                     .where(user_id: current_user.id)
                                     .order(record_time: :desc)
                                     .all
      @balance = current_user.balance
      @payments = @records.where(record_type: :payment)
      @last_payment = -(@payments.first&.amount or 0)
    end
    if @current_user_permissions.include? 'view_management_stats'
      @last_payment_time = TransactionLogRecord.order(record_time: :desc)
                                               .where(record_type: :payment)
                                               .first&.record_time
      @management_records = TransactionLogRecord.includes(:task, :user)
                                                .where('record_time > ?', @last_payment_time)
                                                .order(record_time: :desc)
                                                .all
      @earned_today = -@management_records.pluck(:amount).sum
    end
  end

  def calc_and_make_payment
    DayPaymentProcessor.new.process!

    redirect_to root_path, notice: 'Payment processed successfully'
  end
end