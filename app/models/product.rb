class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_one_attached :image
  has_many_attached :images
  has_many :order_items, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :acceptable_image
  validate :acceptable_images

  scope :on_sale, -> { where(on_sale: true) }
  scope :new_products, -> { where("created_at >= ?", 3.days.ago) }
  scope :recently_updated, -> { where(updated_at: 3.days.ago..) }
  scope :search, ->(term) {
    where("name ILIKE :q OR description ILIKE :q", q: "%#{term}%") if term.present?
  }
  scope :low_stock, -> { where("stock_quantity < ?", 5) }

  def to_s
    name
  end

  def available?
    stock_quantity > 0
  end

  def sale_price
    on_sale? ? (price * 0.9).round(2) : price
  end

  private

  def acceptable_image
    validate_blob(image.blob, :image) if image.attached?
  end

  def acceptable_images
    images.each { |img| validate_blob(img.blob, :images) }
  end

  def validate_blob(blob, attribute)
    if blob.byte_size > 5.megabytes
      errors.add(attribute, "is too large (max 5 MB)")
    end
    unless blob.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(attribute, "must be JPEG, PNG, or WEBP")
    end
  end
end
