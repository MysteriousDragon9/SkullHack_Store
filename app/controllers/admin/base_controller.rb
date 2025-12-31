class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  private

  def require_admin
    unless current_user&.admin?
      Rails.logger.warn("Unauthorized admin access attempt by user_id=#{current_user&.id}")
      redirect_to root_path, alert: "Access denied."
    end
  end
end
