class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  belongs_to :province, optional: true

  validates :address, presence: true, if: -> { province_id.present? }
  validates :province, presence: true, if: -> { address.present? }

  after_create :create_cart

  scope :admins, -> { where(admin: true) }
  scope :customers, -> { where(admin: false) }

  def admin?
    admin
  end

  def to_s
    email
  end

  private

  def create_cart
    Cart.create!(user: self)
  end
end
