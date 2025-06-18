class Photo < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true
  validates :category, presence: true

  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }

  def self.categories
    distinct.pluck(:category).compact.sort
  end
end
