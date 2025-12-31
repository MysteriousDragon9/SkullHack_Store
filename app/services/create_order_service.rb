class CreateOrderService
  class InsufficientStock < StandardError; end
  class InvalidQuantity < StandardError; end
  class DuplicateRequest < StandardError; end

  def initialize(user:, items:, idempotency_key: nil, logger: Rails.logger)
    @user = user
    @items = Array(items)
    @idempotency_key = idempotency_key&.to_s
    @logger = logger
  end

  def call
    validate_input!

    if @idempotency_key.present?
      existing = Order.find_by(idempotency_key: @idempotency_key, user: @user)
      raise DuplicateRequest, "Order already exists with id=#{existing.id}" if existing.present?
    end

    Order.transaction(requires_new: true) do
      order = Order.new(user: @user, status: "pending", idempotency_key: @idempotency_key)

      @items.each do |item|
        product = Product.lock.find(item[:product_id])
        raise ActiveRecord::RecordNotFound, "Product #{item[:product_id]} not found" unless product

        qty = item[:quantity].to_i
        raise InvalidQuantity, "Invalid quantity for product #{product.id}" if qty <= 0

        product.with_lock do
          raise InsufficientStock, "Insufficient stock for product #{product.id}" if product.stock_quantity < qty
          product.update!(stock_quantity: product.stock_quantity - qty)
        end

        order.order_items.build(product: product, quantity: qty, unit_price: product.price)
      end

      order.recalc_totals!
      order.save!

      @logger.info("Order created id=#{order.id} user_id=#{@user.id} idempotency=#{@idempotency_key}")
      order
    end
  end

  private

  def validate_input!
    raise ArgumentError, "user is required" unless @user.present?
    raise ArgumentError, "items must be a non-empty array" unless @items.is_a?(Array) && @items.any?
    @items.each do |item|
      raise ArgumentError, "Each item must include product_id and quantity" unless item[:product_id] && item[:quantity]
    end
  end
end
