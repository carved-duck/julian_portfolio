class Project < ApplicationRecord
  FRAMES = %w[browser phone terminal].freeze
  SECTIONS = %w[work earlier bootcamp].freeze # also the order of the Projects page's eras
  HERO_TITLE = "Menyu".freeze # leads the Projects page

  has_one_attached :featured_image
  has_many_attached :screenshots # extra app screens a phone-frame card flips through
  has_one_attached :icon # app icon for the phone card's App Store-style layout

  validates :title, presence: true
  validates :description, presence: true
  validates :frame, inclusion: { in: FRAMES }
  validates :section, inclusion: { in: SECTIONS }

  scope :recent, -> { order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }
  scope :by_start, -> { order(arel_table[:started_on].desc.nulls_last, created_at: :desc) }

  def has_links?
    github_url.present? || live_url.present?
  end

  def tag_list
    tags&.split(',')&.map(&:strip) || []
  end

  def tag_list=(tags_array)
    self.tags = tags_array.reject(&:blank?).join(', ') if tags_array.is_a?(Array)
  end

  # The project page's "What I built" bullets: one per line of `highlights`.
  def highlight_list
    highlights.to_s.lines.map(&:strip).reject(&:empty?)
  end
end
