class ApplicationController < ActionController::Base

  private

  def current_user_roles
    @current_user_roles ||= current_user.roles.pluck(:name)
  end

  def current_user_permissions
    @current_user_permissions ||= current_user.permissions.pluck(:name)
  end
end
