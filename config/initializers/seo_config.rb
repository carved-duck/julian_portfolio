# SEO Configuration
module SeoConfig
  # Base settings
  SITE_NAME = "Julian Schoenfeld Portfolio"
  SITE_AUTHOR = "Julian Schoenfeld"

  # Social media handles (update these with your actual handles)
  SOCIAL_HANDLES = {
    twitter: "@julianschoenfeld",
    github: "https://github.com/julianschoenfeld",
    linkedin: "https://linkedin.com/in/julianschoenfeld",
    instagram: "https://instagram.com/julianschoenfeld"
  }.freeze

  # Default images for social sharing
  DEFAULT_IMAGE_PATH = "icons/apple-icon.png"

  # Location settings (update these when you move!)
  # Examples:
  # Moving to Berlin: { city: "Berlin", country: "Germany", full_location: "Berlin, Germany" }
  # Moving to NYC: { city: "New York", country: "USA", full_location: "New York, USA" }
  # Moving to London: { city: "London", country: "UK", full_location: "London, UK" }
  LOCATION = {
    city: "Tokyo",
    country: "Japan",
    full_location: "Tokyo, Japan"
  }.freeze

  # Dynamic descriptions based on location
  SITE_DESCRIPTION = "#{LOCATION[:full_location]}-based web developer and photographer specializing in Ruby on Rails applications and creative photography."

  # Structured data configuration
  PERSON_SCHEMA = {
    name: SITE_AUTHOR,
    job_title: "Web Developer & Photographer",
    location: LOCATION,
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
      title_suffix: "Web Developer & Photographer in #{LOCATION[:city]}",
      keywords: ["web", "developer", "photographer", LOCATION[:city].downcase, LOCATION[:country].downcase, "ruby", "rails", "portfolio"]
    },
    projects: {
      title_suffix: "Web Development Portfolio",
      keywords: %w[web development ruby rails javascript projects portfolio]
    },
    blog: {
      title_suffix: "Blog & Articles",
      keywords: ["blog", "web", "development", "photography", LOCATION[:city].downcase, LOCATION[:country].downcase]
    },
    photos: {
      title_suffix: "Photography Portfolio",
      keywords: ["photography", "portfolio", LOCATION[:city].downcase, LOCATION[:country].downcase, "street", "photography"]
    },
    events: {
      title_suffix: "Events & Workshops",
      keywords: ["events", "workshops", "photography", LOCATION[:city].downcase, "meetups"]
    }
  }.freeze

  # Common meta keywords for all pages
  GLOBAL_KEYWORDS = [
    "julian", "schoenfeld", "portfolio", "web", "developer", "photographer",
    LOCATION[:city].downcase, LOCATION[:country].downcase,
    "ruby", "rails", "creative", "professional"
  ].freeze
end
