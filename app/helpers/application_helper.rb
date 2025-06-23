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
        "#{@photo.title if @photo&.title} - Photo | #{base_title}"
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
      "Julian Schoenfeld - Tokyo-based web developer and photographer. Explore my portfolio of web development projects, photography, and creative events in Japan."
    when 'projects#index'
      "Browse Julian's web development projects including Ruby on Rails applications, responsive websites, and creative digital solutions."
    when 'projects#show'
      truncate(strip_tags(@project.description), length: 160) if @project
    when 'photos#index'
      "Explore Julian's photography portfolio capturing life in Tokyo, Japan. Street photography, portraits, and creative visual storytelling."
    when 'photos#show'
      @photo&.description ? truncate(strip_tags(@photo.description), length: 160) : "Photography by Julian Schoenfeld"
    when 'blog_posts#index'
      "Read Julian's blog about web development, photography, life in Japan, and creative insights from Tokyo."
    when 'blog_posts#show'
      truncate(strip_tags(@blog_post.body), length: 160) if @blog_post
    when 'events#index'
      "Join Julian's photography workshops, tech meetups, and creative events in Tokyo. Connect with like-minded creatives."
    when 'events#show'
      truncate(strip_tags(@event.description), length: 160) if @event
    else
      "Julian Schoenfeld - Tokyo-based web developer and photographer showcasing projects, photography, and events in Japan."
    end
  end

  def canonical_url
    request.original_url.split('?').first
  end

  def structured_data_for_project(project)
    {
      "@context": "https://schema.org",
      "@type": "CreativeWork",
      "name": project.title,
      "description": project.description,
      "creator": {
        "@type": "Person",
        "name": "Julian Schoenfeld"
      },
      "url": project_url(project),
      "image": project.featured_image.attached? ? url_for(project.featured_image) : nil,
      "dateCreated": project.created_at.iso8601,
      "dateModified": project.updated_at.iso8601
    }.compact.to_json.html_safe
  end

  def structured_data_for_blog_post(blog_post)
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      "headline": blog_post.title,
      "description": truncate(strip_tags(blog_post.body), length: 160),
      "author": {
        "@type": "Person",
        "name": "Julian Schoenfeld"
      },
      "publisher": {
        "@type": "Person",
        "name": "Julian Schoenfeld"
      },
      "datePublished": blog_post.published_at&.iso8601,
      "dateModified": blog_post.updated_at.iso8601,
      "url": blog_post_url(blog_post),
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": blog_post_url(blog_post)
      }
    }.compact.to_json.html_safe
  end

  def structured_data_for_event(event)
    {
      "@context": "https://schema.org",
      "@type": "Event",
      "name": event.title,
      "description": event.description,
      "organizer": {
        "@type": "Person",
        "name": "Julian Schoenfeld"
      },
      "url": event_url(event),
      "eventStatus": "https://schema.org/EventScheduled",
      "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode"
    }.compact.to_json.html_safe
  end

  def structured_data_for_person
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "name": "Julian Schoenfeld",
      "jobTitle": "Web Developer & Photographer",
      "description": "Tokyo-based web developer and photographer specializing in Ruby on Rails applications and creative photography.",
      "url": root_url,
      "sameAs": [
        # Add your social media URLs here
        # "https://github.com/your-username",
        # "https://linkedin.com/in/your-profile",
        # "https://instagram.com/your-handle"
      ].compact,
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "Tokyo",
        "addressCountry": "JP"
      },
      "knowsAbout": [
        "Web Development",
        "Ruby on Rails",
        "Photography",
        "JavaScript",
        "HTML/CSS"
      ]
    }.to_json.html_safe
  end
end
