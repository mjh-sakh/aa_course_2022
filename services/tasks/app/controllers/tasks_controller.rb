# frozen_string_literal: true

class TasksController < ApplicationController
  TASKS_TOPIC = 'aa_tasks_stream'

  def index
    @tasks = Task.includes(:user).where(status: :open).order(:created_at).all
  end

  def create
    @new_task = Task.new(description: params['description'],
                         user: random_popug)

    return unless @new_task.save

    message = {
      type: 'Task.Assigned',
      data: {
        task_id: @new_task.id,
        description: @new_task.description,
        user_id: @new_task.assignee.user_idx,
        timestamp: Time.now.utc
      }
    }

    Producer.new.publish(
      message,
      topic: TASKS_TOPIC
    )

    redirect_to action: 'index'
  end

  def shuffle
    messages = []
    ApplicationRecord.transaction do
      Task.where(status: :open).each do |task|
        current_assignee = task.assignee
        new_assignee = random_popug

        next if current_assignee == new_assignee

        task.assignee = new_assignee
        task.save

        messages << {
          type: 'Task.Assigned',
          data: {
            task_id: task.id,
            description: task.description,
            user_id: task.assignee.user_idx,
            timestamp: Time.now.utc
          }
        }
      end
    end

    messages.each { |message| ::Producer.new.publish(message, topic: TASKS_TOPIC) }

    redirect_to action: 'index'
  end

  def complete
    task = Task.find(params[:id])
    task.status = :complete
    task.completed_at = Time.now.utc
    task.save!

    message = {
      type: 'Task.Completed',
      data: {
        task_id: task.id,
        description: task.description,
        user_id: task.assignee.user_idx,
        completed_at: task.completed_at
      }
    }

    ::Producer.new.publish(
      message,
      topic: TASKS_TOPIC
    )

    redirect_to action: 'index'
  end

  private

  def random_popug
    User.all.sample
  end
end
