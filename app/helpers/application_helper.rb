module ApplicationHelper
  def format_url(url, add_www: false)
    return url if url.blank?

    formatted_url = url.start_with?('http') ? url : "https://#{url}"

    if add_www && !formatted_url.match?(%r{https?://(www\.|localhost|[\d.]+)})
      formatted_url.sub(%r{https?://}, '\0www.')
    else
      formatted_url
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

  # SEO Methods
  def page_title(title = nil)
    base_title = "Julian Schoenfeld - Web Developer & Photographer"

    if title.present?
      "#{title} | #{base_title}"
    else
      case "#{controller_name}##{action_name}"
      when 'pages#home'
        base_title
      when 'projects#index'
        "Projects & Web Development | #{base_title}"
      when 'projects#show'
        "#{@project.title} - Project | #{base_title}"
      when 'photos#index'
        "Photography Portfolio | #{base_title}"
      when 'photos#show'
        photos_in_category = Photo.by_category(@photo.category).count
        category_display = @photo.category if @photo&.category
        photo_or_photos = photos_in_category > 1 ? "Photos" : "Photo"
        "#{category_display} #{photo_or_photos} | Julian Schoenfeld"
      when 'blog_posts#index'
        "Blog & Articles | #{base_title}"
      when 'blog_posts#show'
        "#{@blog_post.title} | #{base_title}"
      when 'events#index'
        "Events & Workshops | #{base_title}"
      when 'events#show'
        "#{@event.title} - Event | #{base_title}"
      else
        base_title
      end
    end
  end

  def meta_description
    case "#{controller_name}##{action_name}"
    when 'pages#home'
      "Julian Schoenfeld - #{SeoConfig::LOCATION[:full_location]}-based web developer and photographer. Explore my portfolio of web development projects, photography, and creative events in #{SeoConfig::LOCATION[:country]}."
    when 'projects#index'
      "Browse Julian's web development projects including Ruby on Rails applications, responsive websites, and creative digital solutions."
    when 'projects#show'
      truncate(strip_tags(@project.description), length: 160) if @project
    when 'photos#index'
      "Explore Julian's photography portfolio capturing life in #{SeoConfig::LOCATION[:full_location]}. Street photography, portraits, and creative visual storytelling."
    when 'photos#show'
      base_desc = "#{@photo.category if @photo&.category} photography by Julian Schoenfeld"
      if @photo&.location.present?
        "#{base_desc} taken in #{@photo.location}."
      else
        "#{base_desc}."
      end
    when 'blog_posts#index'
      "Read Julian's blog about web development, photography, life in #{SeoConfig::LOCATION[:country]}, and creative insights from #{SeoConfig::LOCATION[:city]}."
    when 'blog_posts#show'
      truncate(strip_tags(@blog_post.body), length: 160) if @blog_post
    when 'events#index'
      "Join Julian's photography workshops, tech meetups, and creative events in #{SeoConfig::LOCATION[:city]}. Connect with like-minded creatives."
    when 'events#show'
      truncate(strip_tags(@event.description), length: 160) if @event
    else
      "Julian Schoenfeld - #{SeoConfig::LOCATION[:full_location]}-based web developer and photographer showcasing projects, photography, and events in #{SeoConfig::LOCATION[:country]}."
    end
  end

  def canonical_url
    request.original_url.split('?').first
  end

  def structured_data_for_project(project)
    return '' unless project

    data = {
      '@context': "https://schema.org",
      '@type': "CreativeWork",
      name: project.title,
      description: project.description,
      creator: {
        '@type': "Person",
        name: "Julian Schoenfeld"
      },
      dateCreated: project.created_at.iso8601
    }

    data["url"] = project.live_url if project.live_url.present?
    data["keywords"] = project.tag_list.join(', ') if project.tag_list.any?

    if project.featured_image.attached?
      data["image"] = {
        '@type': "ImageObject",
        url: request.base_url + rails_blob_path(project.featured_image, only_path: true)
      }
    end

    data.to_json.html_safe
  end

  def structured_data_for_blog_post(blog_post)
    return '' unless blog_post

    {
      '@context': "https://schema.org",
      '@type': "BlogPosting",
      headline: blog_post.title,
      description: truncate(blog_post.body, length: 160),
      author: {
        '@type': "Person",
        name: "Julian Schoenfeld"
      },
      datePublished: blog_post.created_at.iso8601,
      dateModified: blog_post.updated_at.iso8601,
      url: blog_post_url(blog_post)
    }.to_json.html_safe
  end

  def structured_data_for_event(event)
    {
      '@context': "https://schema.org",
      '@type': "Event",
      name: event.title,
      description: event.description,
      organizer: {
        '@type': "Person",
        name: "Julian Schoenfeld"
      },
      url: event_url(event),
      eventStatus: "https://schema.org/EventScheduled",
      eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode"
    }.compact.to_json.html_safe
  end

  def structured_data_for_person
    {
      '@context': "https://schema.org",
      '@type': "Person",
      name: "Julian Schoenfeld",
      jobTitle: "Full-Stack Developer",
      url: request.base_url,
      sameAs: [
        "https://github.com/your-github-username",
        "https://linkedin.com/in/your-linkedin"
      ],
      knowsAbout: [
        "Ruby on Rails",
        "JavaScript",
        "Web Development",
        "Full-Stack Development"
      ]
    }.to_json.html_safe
  end

  def full_title(page_title = '')
    base_title = "Julian Schoenfeld - Full-Stack Developer"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def meta_keywords(keywords = nil)
    base_keywords = "Julian Schoenfeld, Full-Stack Developer, Ruby on Rails, JavaScript, Web Development, Portfolio"
    keywords ? "#{keywords}, #{base_keywords}" : base_keywords
  end

  def category_icon(category)
    case category
    when "Core Stack"
      "code"
    when "Frontend"
      "palette"
    when "Services"
      "cloud"
    when "Tools & Libraries"
      "tools"
    when "Features"
      "star"
    else
      "tag"
    end
  end

  def breadcrumb_structured_data(items)
    list_items = items.map.with_index do |item, index|
      {
        '@type': "ListItem",
        position: index + 1,
        name: item[:name],
        item: item[:url] ? request.base_url + item[:url] : nil
      }.compact
    end

    {
      '@context': "https://schema.org",
      '@type': "BreadcrumbList",
      itemListElement: list_items
    }.to_json.html_safe
  end

  def page_title_for_project(project)
    "#{project.title} - Portfolio Project"
  end

  def page_description_for_project(project)
    truncate(project.description, length: 160)
  end

  def page_keywords_for_project(project)
    project.tag_list.join(', ')
  end
end
