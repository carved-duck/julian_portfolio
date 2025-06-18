class Project < ApplicationRecord
  has_one_attached :featured_image

  validates :title, presence: true
  validates :description, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def has_links?
    github_url.present? || live_url.present?
  end

  def tag_list
    tags&.split(',')&.map(&:strip) || []
  end

  def tag_list=(tags_array)
    self.tags = tags_array.reject(&:blank?).join(', ') if tags_array.is_a?(Array)
  end
end
