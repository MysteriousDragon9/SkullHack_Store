class CheckoutService
  class OutOfStockError < StandardError; end
  class CheckoutError < StandardError; end

  def initialize(user:, cart:, idempotency_key: nil)
    @user = user
    @cart = cart
    @idempotency_key = idempotency_key
  end

  def call
    raise ArgumentError, "No items in cart" if @cart.cart_items.blank?
    raise ArgumentError, "User must have an address" if @user.address.blank?

    province = @user.province
    tax_rate = province&.total_tax_rate.to_f

    order = Order.new(
      user: @user,
      shipping_address: @user.address,
      shipping_province_name: province&.name,
      shipping_tax_rate: tax_rate,
      status: :pending,
      idempotency_key: @idempotency_key # optional if your Order model has this column
    )

    Order.transaction do
      @cart.cart_items.each do |item|
        product = item.product
        product.with_lock do
          raise OutOfStockError, "Not enough stock for #{product.name}" if product.stock_quantity < item.quantity

          product.decrement!(:stock_quantity, item.quantity)
          order.order_items.build(
            product: product,
            quantity: item.quantity,
            unit_price: product.price
          )
        end
      end

      order.recalc_totals!
      order.save! # raises ActiveRecord::RecordInvalid if fails
      @cart.clear!
      order
    end
  rescue ActiveRecord::RecordInvalid => e
    raise CheckoutError, "Checkout failed: #{e.record.errors.full_messages.join(', ')}"
  end
end
