class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def pay
    @order = current_user.orders.find(params[:id])

    if @order.pending?
      @order.update!(payment_id: "test_pi_#{SecureRandom.hex(8)}", status: "paid")
      Rails.logger.info("Test payment captured user=#{current_user.id} order=#{@order.id}")
      OrderMailer.receipt(@order).deliver_later
      redirect_to @order, notice: "✅ Payment captured (test). Receipt sent."
    else
      redirect_to @order, alert: "⚠️ Order cannot be paid."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "⚠️ Order not found."
  end
end
