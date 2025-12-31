class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart, :product, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validate :quantity_available

  before_validation :set_unit_price, on: :create

  delegate :name, :description, to: :product

  scope :for_cart, ->(cart_id) { where(cart_id:) }
  scope :with_products, -> { includes(:product) }

  def line_total
    unit_price.to_d * quantity
  end

  private

  def set_unit_price
    self.unit_price ||= product&.price
  end

  def quantity_available
    return unless product
    if quantity.to_i > product.stock_quantity
      errors.add(:quantity, "is greater than available stock (#{product.stock_quantity})")
    end
  end
end
