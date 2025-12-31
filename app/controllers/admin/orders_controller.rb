class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show update]

  def index
    @orders = Order.includes(:user, :order_items)
                   .order(created_at: :desc)
                   .page(params[:page]).per(20)
  end

  def show; end

  def update
    target_status = order_params[:status]

    unless transition_allowed?(@order.status, target_status)
      flash.now[:alert] = "Invalid status transition from #{@order.status} to #{target_status}."
      return render :show, status: :unprocessable_entity
    end

    if @order.update(order_params)
      Rails.logger.info("Admin user=#{current_user.id} updated order=#{@order.id} to status=#{target_status}")
      redirect_to admin_order_path(@order), notice: "Order ##{@order.id} updated to #{target_status.titleize}."
    else
      flash.now[:alert] = "Update failed: #{@order.errors.full_messages.to_sentence}"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_orders_path, alert: "Order not found."
  end

  def order_params
    params.require(:order).permit(:status)
  end

  def transition_allowed?(current, target)
    case [ current.to_s, target.to_s ]
    in [ "pending", "paid" ] | [ "paid", "shipped" ] | [ "pending", "canceled" ]
      true
    else
      false
    end
  end
end
