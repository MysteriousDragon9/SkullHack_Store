class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError => e
      Rails.logger.error("Stripe webhook JSON parse error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook signature verification failed: #{e.message}")
      return head :bad_request
    end

    case event["type"]
    when "checkout.session.completed"
      session = event["data"]["object"]

      if (order = Order.find_by(id: session["metadata"]["order_id"]))
        order.update!(status: :paid)
        Rails.logger.info("Stripe webhook: Order #{order.id} marked as paid.")
      else
        Rails.logger.warn("Stripe webhook: Order not found for ID #{session['metadata']['order_id']}")
      end

    else
      Rails.logger.info("Stripe webhook received unhandled event type: #{event['type']}")
    end

    head :ok
  end
end
