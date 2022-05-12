# frozen_string_literal: true

# a Permission
class Permission < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :name, presence: true
end

# == Schema Information
#
# Table name: permissions
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
