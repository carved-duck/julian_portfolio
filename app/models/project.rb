class Project < ApplicationRecord
  has_one_attached :featured_image

  validates :title, presence: true
  validates :description, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }

  def has_links?
    github_url.present? || live_url.present?
  end

  def tag_list
    tags&.split(',')&.map(&:strip) || []
  end

  def tag_list=(tags_array)
    self.tags = tags_array.reject(&:blank?).join(', ') if tags_array.is_a?(Array)
  end

  def categorized_tags
    all_tags = tag_list
    return {} if all_tags.empty?

    categorized = {
      "Core Stack" => [],
      "Frontend" => [],
      "Services" => [],
      "Features" => []
    }

    # Categorize tags based on technology type
    all_tags.each do |tag|
      case tag.downcase
      when /ruby on rails|rails|ruby|python|django|node\.?js|express|laravel|php/
        categorized["Core Stack"] << tag
      when /javascript|typescript|react|vue|angular|jquery|html5?|css3?|scss|sass|bootstrap|tailwind|stimulus|turbo|alpine/
        categorized["Frontend"] << tag
      when /postgresql|mysql|sqlite|mongodb|redis|heroku|aws|digital ocean|cloudinary|stripe|sendgrid|twilio/
        categorized["Services"] << tag
      when /seo|pwa|responsive|mobile|accessibility|spam protection|real.?time|api|authentication|admin/
        categorized["Features"] << tag
      else
        # Default to Core Stack for unrecognized tags
        categorized["Core Stack"] << tag
      end
    end

    # Remove empty categories
    categorized.reject { |_, tags| tags.empty? }
  end

  def display_tags_inline
    # For simplified inline display (like in cards)
    important_tags = tag_list.first(4)
    remaining_count = tag_list.length - 4

    if remaining_count > 0
      "#{important_tags.join(', ')} +#{remaining_count} more"
    else
      important_tags.join(', ')
    end
  end
end
