# frozen_string_literal: true

# a Role
class Role < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions

  validates :name, presence: true
end

# == Schema Information
#
# Table name: roles
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
