class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_cart, only: %i[new create]
  before_action :set_order, only: %i[show pay capture]

  def index
    @orders = current_user.orders.includes(order_items: :product)
                       .order(created_at: :desc)
                       .page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.json { render json: @orders.as_json(include: { order_items: { include: :product } }) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @order.as_json(include: { order_items: { include: :product } }) }
    end
  end

  def new
    if @cart.blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end
    @province = current_user.province
    @summary = build_summary(@cart, @province)
  end

  def create
    if @cart.blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    province = current_user.province
    summary = build_summary(@cart, province)

    order = current_user.orders.build(
      shipping_address: current_user.address,
      province: province,
      subtotal: summary[:subtotal],
      gst_amount: summary[:gst],
      pst_amount: summary[:pst],
      hst_amount: summary[:hst],
      total: summary[:total],
      status: :pending
    )

    ActiveRecord::Base.transaction do
      Product.lock.where(id: @cart.keys).find_each do |product|
        qty = @cart[product.id.to_s].to_i
        raise InvalidQuantityError, "Invalid quantity for #{product.name}" if qty <= 0
        raise InsufficientStockError, "Not enough stock for #{product.name}" if product.stock_quantity < qty

        order.order_items.build(
          product: product,
          quantity: qty,
          unit_price: product.price,
          line_total: product.price * qty
        )
      end

      if order.save
        order.order_items.each do |item|
          item.product.decrement!(:stock_quantity, item.quantity)
        end
        session[:cart] = {}
        Rails.logger.info("Order created user=#{current_user.id} order=#{order.id} total=#{order.total}")

        respond_to do |format|
          format.html { redirect_to order_path(order), notice: "Order created. Proceed to payment." }
          format.json { render json: { order_id: order.id, total: order.total }, status: :created }
        end
      else
        respond_to do |format|
          format.html { redirect_to cart_path, alert: "Could not create order: #{order.errors.full_messages.to_sentence}" }
          format.json { render json: { errors: order.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  rescue StandardError => e
    respond_to do |format|
      format.html { redirect_to cart_path, alert: "Checkout failed: #{e.message}" }
      format.json { render json: { errors: [ e.message ] }, status: :unprocessable_entity }
    end
  end

  def pay
  if @order.pending?
    # Create a Stripe Checkout Session
    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: @order.order_items.map do |item|
        {
          price_data: {
            currency: "usd", # or 'cad' if you want Canadian dollars
            product_data: { name: item.product.name },
            unit_amount: (item.unit_price * 100).to_i # Stripe expects cents
          },
          quantity: item.quantity
        }
      end,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: cart_url,
      metadata: { order_id: @order.id }
    )

    # Redirect user to Stripe Checkout
    redirect_to session.url, allow_other_host: true
  else
    redirect_to @order, alert: "Order is not payable."
  end
    end
  def capture
    if @order.pending?
      @order.update!(status: :paid)
      OrderMailer.receipt(@order).deliver_later
      Rails.logger.info("Payment captured user=#{current_user.id} order=#{@order.id}")
      redirect_to @order, notice: "Payment captured. Receipt sent."
    else
      redirect_to @order, alert: "Order cannot be paid."
    end
  end

  private

  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end

  def build_summary(cart, province)
    subtotal = Product.where(id: cart.keys).sum do |product|
      product.price * cart[product.id.to_s].to_i
    end
    gst = province&.gst.to_f * subtotal
    pst = province&.pst.to_f * subtotal
    hst = province&.hst.to_f * subtotal
    total = subtotal + gst + pst + hst
    { subtotal:, gst:, pst:, hst:, total: }
  end
end
