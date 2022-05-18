# frozen_string_literal: true

# a Task
class Task < ApplicationRecord
  enum status: { open: 0, complete: 1 }

  belongs_to :user
  has_many :transaction_log_records, foreign_key: :reference_id

  alias_attribute :assignee, :user
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
#
