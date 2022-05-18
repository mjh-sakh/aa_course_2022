# frozen_string_literal: true

class TransactionLogRecord < ApplicationRecord
  enum record_type: {
    billing: 0,
    reward: 1,
    payment: 2,
    correction: 3
  }

  belongs_to :task, foreign_key: :reference_id, optional: true
  belongs_to :user

end

# == Schema Information
#
# Table name: transaction_log_records
#
#  id           :uuid             not null, primary key
#  user_id      :uuid             not null
#  event_time   :datetime         not null
#  record_time  :datetime         not null
#  amount       :float            not null
#  record_type  :integer          not null
#  reference_id :uuid
#  note         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
