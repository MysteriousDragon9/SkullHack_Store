class CartItemsController < ApplicationController
  before_action :load_cart

  def create
    product  = Product.find(params[:product_id])
    quantity = params[:quantity].to_i.clamp(1, 999)

    if product.stock_quantity < quantity
      redirect_to product_path(product), alert: "Not enough stock available."
    else
      @cart[product.id.to_s] = (@cart[product.id.to_s] || 0) + quantity
      save_cart!
      redirect_to cart_path, notice: "#{product.name} was added to your cart."
    end
  end

  def update
    product_id = params[:id].to_s
    quantity   = params[:quantity].to_i

    if quantity <= 0
      @cart.delete(product_id)
      message = "Product was removed from your cart."
    else
      @cart[product_id] = quantity
      message = "Product quantity was updated."
    end

    save_cart!
    redirect_to cart_path, notice: message
  end

  def destroy
    product_id = params[:id].to_s
    @cart.delete(product_id)
    save_cart!
    redirect_to cart_path, notice: "Product was removed from your cart."
  end

  private

  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def save_cart!
    session[:cart] = @cart
    Rails.logger.info("Cart updated user=#{current_user&.id} cart=#{@cart.inspect}")
  end
end
