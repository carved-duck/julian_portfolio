class Photo < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true
  validates :category, presence: true
  
  validate :image_content_type

  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_roll_order, -> { order(:created_at, :id) } # oldest upload first, like frames on a roll
  scope :featured, -> { where(featured: true) }

  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def feature!
    # If another photo in the same category is already featured, unfeature it
    Photo.transaction do
      Photo.where(category: category, featured: true).where.not(id: id).update_all(featured: false)
      update!(featured: true)
    end
  end

  def unfeature!
    update!(featured: false)
  end

  private

  def image_content_type
    return unless image.attached?
    
    unless image.content_type.in?(%w[image/jpeg image/jpg image/png image/gif image/webp image/avif])
      errors.add(:image, 'must be a valid image file (JPEG, PNG, GIF, WebP, or AVIF)')
    end
  end
end
