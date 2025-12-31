class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:mailer, :default_from) || "no-reply@yourapp.com",
          reply_to: "support@yourapp.com"
  layout "mailer"

  private

  def app_signature
    "Thanks,\nThe #{Rails.application.class.module_parent_name} Team"
  end
end
