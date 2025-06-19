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
end
