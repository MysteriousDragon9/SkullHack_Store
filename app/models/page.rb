class Page < ApplicationRecord
  validates :title, presence: { message: "Title cannot be blank" }
  validates :content, presence: { message: "Content cannot be blank" }
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create

  scope :alphabetical, -> { order(:title) }
  scope :recent, -> { order(created_at: :desc) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= title.parameterize if title.present?
  end
end
