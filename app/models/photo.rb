class Photo < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true
  validates :category, presence: true

  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }

  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def feature!
    # If another photo in the same category is already featured, unfeature it
    Photo.where(category: category, featured: true).where.not(id: id).update_all(featured: false)
    update!(featured: true)
  end

  def unfeature!
    update!(featured: false)
  end
end
