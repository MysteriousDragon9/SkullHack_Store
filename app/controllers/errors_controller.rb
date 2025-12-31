class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render template: "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: "Not Found" }, status: :not_found }
    end
  end

  def internal_error
    Rails.logger.error("Internal server error at #{request.path}")
    respond_to do |format|
      format.html { render template: "errors/internal_error", status: :internal_server_error, layout: "application" }
      format.json { render json: { error: "Internal Server Error" }, status: :internal_server_error }
    end
  end
end
