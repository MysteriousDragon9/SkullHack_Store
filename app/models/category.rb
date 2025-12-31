class Category < ApplicationRecord
  has_many :products, dependent: :destroy
   has_one_attached :image

  validates :name, presence: { message: "Category name cannot be blank" },
                   uniqueness: { case_sensitive: false, message: "Category name must be unique" }

  scope :alphabetical, -> { order(:name) }
  scope :with_products, -> { includes(:products).where.not(products: { id: nil }) }
  scope :empty, -> { left_outer_joins(:products).where(products: { id: nil }) }

  def to_s
    name
  end

  before_validation :generate_slug

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
