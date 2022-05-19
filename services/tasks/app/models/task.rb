# frozen_string_literal: true

# a Task
class Task < ApplicationRecord
  enum status: { open: 0, complete: 1 }

  belongs_to :user

  validates :description, presence: true
  validates :status, presence: true
  validates :description, format: { without: /\[.+\]/ }

  alias_attribute :assignee, :user
end

# == Schema Information
#
# Table name: tasks
#
#  id           :uuid             not null, primary key
#  description  :string           not null
#  user_id      :uuid
#  status       :integer          default("open")
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  jira_id      :string
#
