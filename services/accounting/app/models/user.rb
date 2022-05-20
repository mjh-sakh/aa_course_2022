# frozen_string_literal: true

# a User
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[aa_auth]
  enum status: { deactivated: 0, active: 1 }

  has_and_belongs_to_many :roles
  has_many :tasks
  has_many :transaction_log_records

  def permissions
    return [] unless roles

    roles.includes(:permissions).map(&:permissions).flatten.uniq
  end
end

# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  user_idx   :uuid             not null
#  name       :string
#  email      :string
#  status     :integer          default("active")
#  balance    :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
