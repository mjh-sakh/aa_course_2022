# frozen_string_literal: true

class TasksController < ApplicationController
  # 'aa' stands for 'Async Architecture' course name
  TASKS_TOPIC_CUD = 'aa_tasks_stream'
  TASKS_TOPIC_BE = 'aa_tasks_lifecycle'

  before_action :authenticate_user!, except: :login
  before_action do
    if current_user
      current_user_roles
      current_user_permissions
    end
  end

  def login; end

  def index
    @tasks = Task.includes(:user).where(status: :open).order(:created_at).all
  end

  def create
    return unless @permissions.include? 'add_new_task'

    @new_task = Task.new(description: params['description'],
                         user: random_popug)

    return unless @new_task.save

    message = {
      message_name: 'TaskCreated',
      data: {
        task_id: @new_task.id,
        description: @new_task.description,
        user_id: @new_task.assignee.user_idx,
        timestamp: Time.now.utc
      }
    }

    Producer.new.publish(
      message,
      topic: TASKS_TOPIC_BE
    )

    redirect_to action: 'index'
  end

  def shuffle
    return unless @permissions.include? 'shuffle_open_tasks'

    messages = []
    open_tasks = Task.where(status: :open)
    ApplicationRecord.transaction do
      open_tasks.each do |task|
        current_assignee_id = task.user_id # id only to avoid extra db hit
        new_assignee = random_popug

        next if current_assignee_id == new_assignee.id

        task.assignee = new_assignee
        task.save

        messages << {
          message_name: 'TaskAssigned',
          data: {
            task_id: task.id,
            description: task.description,
            user_id: task.assignee.user_idx,
            timestamp: Time.now.utc
          }
        }
      end
    end

    messages.each { |message| ::Producer.new.publish(message, topic: TASKS_TOPIC_BE) }

    redirect_to action: 'index'
  end

  def complete
    task = Task.find(params[:id])
    return unless (@permissions.include? 'complete_own_tasks' and task.assignee == current_user) or
      @permissions.include? 'complete_all_tasks'

    task.status = :complete
    task.completed_at = Time.now.utc
    task.save!

    message = {
      message_name: 'TaskCompleted',
      data: {
        task_id: task.id,
        description: task.description,
        assignee_id: task.assignee.user_idx,
        completed_by_id: current_user.user_idx, # i.e. can be closed by admin
        completed_at: task.completed_at
      }
    }

    ::Producer.new.publish(
      message,
      topic: TASKS_TOPIC_BE
    )

    redirect_to action: 'index'
  end

  private

  def random_popug
    @workers ||= User.joins(:roles)
                     .where('roles.name': 'worker')
                     .all
    @workers.sample
  end

  def current_user_roles
    @roles ||= current_user.roles.pluck(:name)
  end

  def current_user_permissions
    @permissions ||= current_user.permissions.pluck(:name)
  end
end
