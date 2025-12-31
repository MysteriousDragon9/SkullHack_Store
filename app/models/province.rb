class Province < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :gst, :pst, :hst,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 },
            allow_nil: true

  scope :with_tax, -> { where("gst > 0 OR pst > 0 OR hst > 0") }
  scope :no_tax, -> { where(gst: 0, pst: 0, hst: 0) }
  scope :alphabetical, -> { order(:name) }

  def total_tax_rate
    (gst || 0) + (pst || 0) + (hst || 0)
  end

  def to_s
    name
  end
end
