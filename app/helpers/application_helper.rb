module ApplicationHelper
  def format_url(url, add_www: false)
    return nil if url.blank?

    if url.start_with?('http://', 'https://')
      url
    elsif add_www && !url.start_with?('www.')
      "https://www.#{url}"
    elsif url.start_with?('www.')
      "https://#{url}"
    else
      "https://#{url}"
    end
  end

  def body_class
    case controller_name
    when 'projects'
      'projects-page'  # Spring - Cherry Blossom
    when 'photos'
      'photos-page'    # Summer - Warm Gold Sunset
    when 'blog_posts'
      'blog-page'      # Fall - Maple Leaves
    when 'submissions'
      'events-page'    # Winter - Cool Blues
    else
      'default-page'
    end
  end
end
