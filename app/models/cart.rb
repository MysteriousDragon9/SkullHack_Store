class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def add_product(product, qty = 1)
    raise ArgumentError, "product must be present" unless product
    qty = qty.to_i
    raise ArgumentError, "quantity must be positive" if qty <= 0
    raise ArgumentError, "quantity exceeds available stock" if qty > product.stock_quantity

    item = cart_items.find_by(product_id: product.id)
    if item
      item.with_lock do
        item.update!(quantity: item.quantity + qty)
      end
      item
    else
      cart_items.create!(product: product, quantity: qty, unit_price: product.price)
    end
  end

  def update_item(product_id, qty)
    qty = qty.to_i
    item = cart_items.find_by(product_id: product_id)
    raise ActiveRecord::RecordNotFound, "Cart item not found" unless item

    if qty <= 0
      item.destroy!
      return nil
    else
      raise ArgumentError, "quantity exceeds available stock" if qty > item.product.stock_quantity
      item.update!(quantity: qty)
    end
    item
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    item&.destroy!
  end

  def total_price
    cart_items.sum("unit_price * quantity").to_d.round(2)
  end

  def to_order_items
    cart_items.map do |ci|
      { product_id: ci.product_id, quantity: ci.quantity, unit_price: ci.unit_price }
    end
  end

  def clear!
    cart_items.delete_all
  end
end
