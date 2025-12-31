class OrderMailer < ApplicationMailer
  default from: Rails.application.credentials.dig(:mailer, :default_from) || "no-reply@skullhack.store",
          reply_to: "support@skullhack.store"

  def receipt(order)
    @order = order
    mail to: order.user.email,
         subject: I18n.t("order_mailer.receipt.subject", id: order.id)
  end
end
