# SEO Configuration
module SeoConfig
  # Base settings
  SITE_NAME = "Julian Schoenfeld Portfolio"
  SITE_AUTHOR = "Julian Schoenfeld"
  SITE_DESCRIPTION = "Tokyo-based web developer and photographer specializing in Ruby on Rails applications and creative photography."

  # Social media handles (update these with your actual handles)
  SOCIAL_HANDLES = {
    twitter: "@julianschoenfeld",
    github: "https://github.com/julianschoenfeld",
    linkedin: "https://linkedin.com/in/julianschoenfeld",
    instagram: "https://instagram.com/julianschoenfeld"
  }.freeze

  # Default images for social sharing
  DEFAULT_IMAGE_PATH = "icons/apple-icon.png"

  # Structured data configuration
  PERSON_SCHEMA = {
    name: SITE_AUTHOR,
    job_title: "Web Developer & Photographer",
    location: {
      city: "Tokyo",
      country: "Japan"
    },
    skills: [
      "Ruby on Rails",
      "JavaScript",
      "HTML/CSS",
      "Photography",
      "Web Development"
    ]
  }.freeze

  # Page-specific SEO settings
  PAGE_SETTINGS = {
    home: {
      title_suffix: "Web Developer & Photographer in Tokyo",
      keywords: %w[web developer photographer tokyo japan ruby rails portfolio]
    },
    projects: {
      title_suffix: "Web Development Portfolio",
      keywords: %w[web development ruby rails javascript projects portfolio]
    },
    blog: {
      title_suffix: "Blog & Articles",
      keywords: %w[blog web development photography tokyo japan]
    },
    photos: {
      title_suffix: "Photography Portfolio",
      keywords: %w[photography portfolio tokyo japan street photography]
    },
    events: {
      title_suffix: "Events & Workshops",
      keywords: %w[events workshops photography tokyo meetups]
    }
  }.freeze

  # Common meta keywords for all pages
  GLOBAL_KEYWORDS = %w[
    julian schoenfeld portfolio web developer photographer tokyo japan
    ruby rails creative professional
  ].freeze
end
