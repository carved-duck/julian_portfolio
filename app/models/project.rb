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
      "Tools & Libraries" => [],
      "Features" => []
    }

    # Categorize tags based on technology type
    all_tags.each do |tag|
      tag_lower = tag.downcase

      case tag_lower
      # Core programming languages and main frameworks
      when /^(ruby on rails|rails|ruby|python|django|node\.?js|express|laravel|php|java|c#|golang|rust)$/
        categorized["Core Stack"] << tag

      # Frontend technologies
      when /javascript|typescript|react|vue|angular|jquery|html5?|css3?|scss|sass|bootstrap|tailwind|stimulus|turbo|alpine|svelte|ember/
        categorized["Frontend"] << tag

      # Third-party services and APIs
      when /postgresql|mysql|sqlite|mongodb|redis|heroku|aws|digital ocean|cloudinary|stripe|sendgrid|twilio|mapbox|spotify api|google maps|firebase|netlify|vercel/
        categorized["Services"] << tag

      # Tools, libraries, and gems
      when /selenium|webdriver|nokogiri|rspec|minitest|jest|cypress|webpack|babel|eslint|rubocop|sidekiq|devise|pundit|factory|faker|capybara|chromedriver/
        categorized["Tools & Libraries"] << tag

      # Features and capabilities
      when /seo|pwa|responsive|mobile|accessibility|spam protection|real.?time|api|authentication|admin|web scraping|ocr|tesseract|pdf|csv|json|xml|oauth|jwt|caching|optimization|testing|deployment/
        categorized["Features"] << tag

      # Special handling for compound terms
      when /ocr.*tesseract|tesseract.*ocr/
        categorized["Features"] << tag
      when /selenium.*webdriver|webdriver.*selenium/
        categorized["Tools & Libraries"] << tag

      else
        # For unrecognized tags, try to infer from context
        if tag_lower.include?('api') || tag_lower.include?('service')
          categorized["Services"] << tag
        elsif tag_lower.include?('gem') || tag_lower.include?('library') || tag_lower.include?('tool')
          categorized["Tools & Libraries"] << tag
        elsif tag_lower.end_with?('js') || tag_lower.end_with?('css') || tag_lower.include?('frontend')
          categorized["Frontend"] << tag
        else
          # Put truly unknown tags in Features as a catch-all
          categorized["Features"] << tag
        end
      end
    end

    # Remove empty categories
    categorized.reject { |_, tags| tags.empty? }
  end

  def display_tags_inline
    # For simplified inline display (like in cards)
    important_tags = tag_list.first(4)
    remaining_count = tag_list.length - 4

    if remaining_count.positive?
      "#{important_tags.join(', ')} +#{remaining_count} more"
    else
      important_tags.join(', ')
    end
  end
end
