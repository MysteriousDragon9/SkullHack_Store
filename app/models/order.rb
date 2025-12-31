class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province, optional: true
  has_many :order_items, dependent: :destroy

  # Use integer-backed enums for cleaner queries and helpers
  enum status: { pending: 0, paid: 1, canceled: 2, shipped: 3 }

  before_save :prevent_total_changes_when_paid
  before_validation :recalc_totals!, unless: :paid?

  validates :user, presence: true
  validates :status, presence: true
  validates :subtotal, :tax_total, :grand_total,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  scope :recent,          -> { order(created_at: :desc) }
  scope :paid_orders,     -> { paid }
  scope :canceled_orders, -> { canceled }
  scope :shipped_orders,  -> { shipped }

  # --- Public methods ---

  def recalc_totals!
    self.subtotal    = order_items.sum(:line_total).to_d
    # If province has tax rates, calculate them
    gst = province&.gst.to_f * subtotal
    pst = province&.pst.to_f * subtotal
    hst = province&.hst.to_f * subtotal
    self.tax_total   = (gst + pst + hst).round(2)
    self.grand_total = (subtotal + tax_total).round(2)
  end

  # Convenience alias so views can call order.total
  def total
    grand_total
  end

  private

  def prevent_total_changes_when_paid
    return unless paid? && will_save_change_to_grand_total?
    errors.add(:base, "Paid orders cannot change totals")
    throw :abort
  end
end
