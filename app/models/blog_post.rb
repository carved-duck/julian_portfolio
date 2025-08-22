class BlogPost < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true

  before_save :generate_slug, if: -> { slug.blank? || title_changed? }

  scope :published, -> { where.not(published_at: nil) }
  scope :recent, -> { order(published_at: :desc) }

  def published?
    published_at.present?
  end

  def to_param
    slug.presence || id
  end

  private

  def generate_slug
    base_slug = title.parameterize
    existing_slug = BlogPost.where(slug: base_slug).where.not(id: id).exists?

    if existing_slug
      counter = 1
      loop do
        new_slug = "#{base_slug}-#{counter}"
        break unless BlogPost.where(slug: new_slug).where.not(id: id).exists?

        counter += 1
      end
      self.slug = new_slug
    else
      self.slug = base_slug
    end
  end
end
