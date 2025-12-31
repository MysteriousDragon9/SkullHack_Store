class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order, :product, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_prices

  delegate :name, :description, to: :product

  scope :for_order, ->(order_id) { where(order_id:) }
  scope :with_products, -> { includes(:product) }

  private

  def set_prices
    return unless product && quantity
    self.unit_price ||= product.price
    self.line_total = (unit_price.to_d * quantity).round(2)
  end
end
