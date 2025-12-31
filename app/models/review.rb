class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user, :product, :rating, presence: true
  validates :rating, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_product, ->(product_id) { where(product_id:) }
  scope :by_user, ->(user_id) { where(user_id:) }

  def stars
    "★" * rating + "☆" * (5 - rating)
  end

  def stars_html
    full = "★" * rating
    empty = "☆" * (5 - rating)
    "<span class='stars'>#{full}#{empty}</span>".html_safe
  end
end
