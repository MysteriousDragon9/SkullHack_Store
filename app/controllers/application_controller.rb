class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_security_headers

  private

  def render_not_found(exception)
    respond_to do |format|
      format.json { render json: { error: exception.message }, status: :not_found }
      format.html { render file: Rails.root.join("public/404.html"), status: :not_found, layout: false }
    end
  end

  def render_unprocessable(exception)
    messages = exception.respond_to?(:record) ? exception.record.errors.full_messages : [ exception.message ]
    render json: { errors: messages }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def set_security_headers
    response.set_header("X-Content-Type-Options", "nosniff")
    response.set_header("X-Frame-Options", "SAMEORIGIN")
  end

  protected

  def configure_permitted_parameters
    keys = %i[name address province_id]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end
end
