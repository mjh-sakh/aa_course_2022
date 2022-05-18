# frozen_string_literal: true

class AnalyticsController < ApplicationController

  before_action :authenticate_user!, except: :login
  before_action do
    @page_title = 'Analytics'
    if current_user
      current_user_roles
      current_user_permissions
    end
    unless current_user_roles.include? 'admin'
      redirect_to login_path, alert: 'Only admins can see analytics'
    end
  end

  def login
    redirect_to login_path
  end

  def index
    @last_payment_time = TransactionLogRecord.order(record_time: :desc)
                                             .where(record_type: :payment)
                                             .first&.record_time
    @management_records = TransactionLogRecord.includes(:task, :user)
                                              .where('record_time > ?', @last_payment_time)
                                              .order(record_time: :desc)
                                              .all
    @earned_today = -@management_records.pluck(:amount).sum

    @poor_workers = User.joins(:roles).where('roles.name': 'worker').where('balance < ?', 0).all

    periods = [1, 7, 30]
    tasks = Task.where(status: :complete)
                .where('completed_at > ?', Time.now - periods.max.hours)
                .all
    last_period = 0
    @most_payed_tasks_per_period = periods.map do |period|
      task = tasks.where('completed_at > ?', Time.now - period.hours)
                  .where('completed_at < ?', Time.now - last_period.hours)
                  .order(reward: :desc)
                  .first
      last_period = period
      [period, task&.reward, task&.description, task&.completed_at]
    end
  end

  def recalc_users_balances
    @records = TransactionLogRecord.all
    count = 0
    ActiveRecord::Base.transaction do
      User.where(status: :active).each do |user|
        true_balance = @records.where(user: user).pluck(:amount).sum
        next if user.balance == true_balance

        user.update(balance: true_balance)
        count += 1
      end
    end

    redirect_to analytics_path, notice: "Updated for #{count} users"
  end
end
