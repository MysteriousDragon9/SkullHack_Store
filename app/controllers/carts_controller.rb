class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    # Preload products to avoid N+1 queries
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_item
    product = Product.find(cart_item_params[:product_id])
    qty     = cart_item_params[:quantity].to_i

    if qty <= 0
      return redirect_to cart_path, alert: "Quantity must be greater than zero"
    end

    if product.stock_quantity < qty
      return redirect_to cart_path, alert: "Not enough stock for #{product.name}"
    end

    @cart.add_product(product, qty)
    Rails.logger.info("Cart add_item user=#{current_user.id} cart=#{@cart.id} product=#{product.id} qty=#{qty}")
    redirect_to cart_path, notice: "#{product.name} added to cart"
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Product not found"
  end

  def update_item
    product = Product.find(cart_item_params[:product_id])
    qty     = cart_item_params[:quantity].to_i

    if qty <= 0
      return redirect_to cart_path, alert: "Quantity must be greater than zero"
    end

    if qty > product.stock_quantity
      return redirect_to cart_path, alert: "Not enough stock for #{product.name}"
    end

    @cart.update_item(product.id, qty)
    Rails.logger.info("Cart update_item user=#{current_user.id} cart=#{@cart.id} product=#{product.id} qty=#{qty}")
    redirect_to cart_path, notice: "Updated #{product.name} quantity"
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found"
  end

  def remove_item
    product_id = cart_item_params[:product_id]

    if @cart.remove_product(product_id)
      Rails.logger.info("Cart remove_item user=#{current_user.id} cart=#{@cart.id} product=#{product_id}")
      redirect_to cart_path, notice: "Removed product from cart"
    else
      redirect_to cart_path, alert: "Product not found in cart"
    end
  end

  def checkout
    if current_user.address.blank? || current_user.province_id.blank?
      return redirect_to edit_user_registration_path,
                         alert: "Please add your shipping address and province before checkout"
    end

    idempotency = request.headers["Idempotency-Key"] || params[:idempotency_key]
    items       = @cart.to_order_items

    if items.blank?
      return redirect_to cart_path, alert: "Cart is empty"
    end

    service = CheckoutService.new(user: current_user, cart: @cart, idempotency_key: idempotency)
    order   = service.call

    @cart.clear!
    Rails.logger.info("Checkout user=#{current_user.id} cart=#{@cart.id} order=#{order.id} subtotal=#{order.subtotal} tax=#{order.tax_total} total=#{order.grand_total}")

    redirect_to order_path(order), notice: "Order placed successfully"
  rescue StandardError => e
    Rails.logger.error("Checkout failed user=#{current_user.id} cart=#{@cart.id} error=#{e.message}")
    redirect_to cart_path, alert: e.message
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def cart_item_params
    params.permit(:product_id, :quantity)
  end
end
