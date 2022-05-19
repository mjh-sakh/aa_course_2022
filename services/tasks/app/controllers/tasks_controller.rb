# frozen_string_literal: true

class TasksController < ApplicationController

  class MessageWasNotPublished < StandardError; end

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

    @new_task = Task.new(jira_id: params['jira_id'],
                         description: params['description'],
                         user: random_popug)

    if @new_task.save
      message = {
        message_name: 'TaskCreated',
        message_version: 2,
        message_time: Time.now,
        producer: 'task_service',
        data: {
          task_id: @new_task.id,
          jira_id: @new_task.jira_id,
          description: @new_task.description,
          assignee_id: @new_task.assignee.user_idx,
          timestamp: Time.now.utc
        }
      }

      begin
        SchemaValidator.new(message, :TaskCreated_v2).validate!
        Producer.new.publish(message, topic: TASKS_TOPIC_BE)
      rescue
        logger.warn "Error occurred when publishing tasks BE"
        logger.warn message
        logger.warn [MessageWasNotPublished, $!.to_s, $!.backtrace]
      end
      redirect_to action: 'index'
    else
      redirect_to root_path, alert: 'Error'
    end
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
          message_version: 2,
          message_time: Time.now,
          producer: 'task_service',
          data: {
            task_id: task.id,
            jira_id: task.jira_id,
            description: task.description,
            assignee_id: task.assignee.user_idx,
            timestamp: Time.now.utc
          }
        }
      end
    end

    messages.each do |message|
      SchemaValidator.new(message, :TaskAssigned_v2).validate!
      Producer.new.publish(message, topic: TASKS_TOPIC_BE)
    rescue
      logger.warn "Error occurred when publishing tasks BE"
      logger.warn message
      logger.warn [MessageWasNotPublished, $!.to_s, $!.backtrace]
    end

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
      message_version: 2,
      message_time: Time.now,
      producer: 'task_service',
      data: {
        task_id: task.id,
        jira_id: task.jira_id,
        description: task.description,
        assignee_id: task.assignee.user_idx,
        completed_by_id: current_user.user_idx, # i.e. can be closed by admin
        timestamp: task.completed_at
      }
    }
    begin
      SchemaValidator.new(message, :TaskCompleted_v2).validate!
      Producer.new.publish(message, topic: TASKS_TOPIC_BE)
    rescue
      logger.warn "Error occurred when publishing tasks BE"
      logger.warn message
      logger.warn [MessageWasNotPublished, $!.to_s, $!.backtrace]
    end
    redirect_to action: 'index'
  end

  def resend_all_tasks
    count = 0
    Task.includes(:user).all.each do |task|
      count += 1
      message = {
        message_name: 'TaskUpdated',
        message_version: 2,
        message_time: Time.now,
        producer: 'task_service',
        data: {
          task_id: task.id,
          jira_id: task.jira_id,
          description: task.description,
          assignee_id: task.assignee.user_idx,
          status: task.status,
          timestamp: task.completed_at
        }
      }
      begin
        SchemaValidator.new(message, :TaskUpdated_v2).validate!
        Producer.new.publish(message, topic: TASKS_TOPIC_CUD)
      rescue
        logger.warn "Error occurred when publishing tasks CUD message"
        logger.warn message
        logger.warn [MessageWasNotPublished, $!.to_s, $!.backtrace]
      end
    end

    redirect_to root_path, notice: "Information about #{count} task(s) was resent."
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
