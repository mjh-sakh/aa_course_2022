# frozen_string_literal: true

# a User
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: %i[aa_auth]
  enum status: { deactivated: 0, active: 1 }

  has_and_belongs_to_many :roles

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
#  user_idx   :uuid
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
