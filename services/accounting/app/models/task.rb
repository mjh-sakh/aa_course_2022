# frozen_string_literal: true

# a Task
class Task < ApplicationRecord
  COST_RANGE = 10..20
  REWARD_RANGE = 20..40

  after_create :rate_task

  enum status: { open: 0, complete: 1 }

  belongs_to :user
  has_many :transaction_log_records, foreign_key: :reference_id

  alias_attribute :assignee, :user

  private

  def rate_task
    self.cost = rand(COST_RANGE)
    self.reward = rand(REWARD_RANGE)
    save!
  end
end

# == Schema Information
#
# Table name: tasks
#
#  id           :uuid             not null, primary key
#  task_idx     :uuid             not null
#  description  :string           not null
#  user_id      :uuid
#  status       :integer          default("open")
#  completed_at :datetime
#  cost         :float
#  reward       :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  jira_id      :string
#
