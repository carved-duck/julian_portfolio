class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Add security headers
  before_action :set_security_headers
  # Track unique visitors and page views
  before_action :track_visitor
  before_action :track_page_view

  private

  def set_security_headers
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'DENY'

    # Prevent MIME type sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'

    # Enable XSS protection
    response.headers['X-XSS-Protection'] = '1; mode=block'

    # Referrer policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

    # Don't allow the page to be cached
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end

  def track_visitor
    # Skip tracking for admin pages to avoid inflating counts
    return if request.path.start_with?('/admin')
    return if is_bot_request?

    # Create a more unique visitor fingerprint
    visitor_fingerprint = generate_visitor_fingerprint

    # Check if this fingerprint has been seen in the last 24 hours
    cache_key = "visitor_#{visitor_fingerprint}"
    unless Rails.cache.exist?(cache_key)
      # New unique visitor within 24 hours
      increment_visitor_count

      # Cache this fingerprint for 24 hours to avoid double counting
      Rails.cache.write(cache_key, Time.current, expires_in: 24.hours)

      # Store visitor info for analytics
      store_visitor_info(visitor_fingerprint)
    end

    # Always mark session as tracked for faster subsequent requests
    session[:visitor_tracked] = true
  end

  def track_page_view
    # Skip tracking for admin pages and bots
    return if request.path.start_with?('/admin')
    return if is_bot_request?

    # Track every page view
    page_views = Rails.cache.fetch('total_page_views', expires_in: 1.year) { 0 }
    Rails.cache.write('total_page_views', page_views + 1, expires_in: 1.year)

    # Track popular pages
    page_key = "page_#{sanitize_path(request.path)}"
    page_count = Rails.cache.fetch(page_key, expires_in: 1.year) { 0 }
    Rails.cache.write(page_key, page_count + 1, expires_in: 1.year)
  end

  def generate_visitor_fingerprint
    # Combine IP, User Agent, and Accept-Language for uniqueness
    components = [
      request.remote_ip,
      request.user_agent.to_s[0..100], # Truncate to avoid huge cache keys
      request.headers['Accept-Language'].to_s[0..50]
    ]

    # Create a hash for storage efficiency
    Digest::SHA256.hexdigest(components.join('|'))
  end

  def is_bot_request?
    user_agent = request.user_agent.to_s.downcase

    # Common bot patterns
    bot_patterns = [
      'bot', 'crawl', 'spider', 'scrape', 'fetch', 'curl', 'wget',
      'monitor', 'check', 'scan', 'test', 'validator', 'lighthouse'
    ]

    bot_patterns.any? { |pattern| user_agent.include?(pattern) }
  end

  def increment_visitor_count
    current_count = Rails.cache.fetch('visitor_count', expires_in: 1.year) { 0 }
    Rails.cache.write('visitor_count', current_count + 1, expires_in: 1.year)
  end

  def store_visitor_info(fingerprint)
    # Store recent visitor data for analytics (keep last 1000 visitors)
    visitors_key = 'recent_visitors'
    recent_visitors = Rails.cache.fetch(visitors_key, expires_in: 30.days) { [] }

    visitor_data = {
      fingerprint: fingerprint[0..8], # Store short version for privacy
      ip: anonymize_ip(request.remote_ip),
      user_agent: request.user_agent.to_s[0..100],
      referrer: request.referer.to_s[0..100],
      timestamp: Time.current.iso8601,
      landing_page: request.path
    }

    recent_visitors.unshift(visitor_data)
    recent_visitors = recent_visitors.first(1000) # Keep only last 1000

    Rails.cache.write(visitors_key, recent_visitors, expires_in: 30.days)
  end

  def anonymize_ip(ip)
    # Anonymize IP for privacy (remove last octet for IPv4)
    if ip.include?('.')
      parts = ip.split('.')
      parts[-1] = 'xxx'
      parts.join('.')
    else
      # For IPv6, just show first part
      ip.split(':').first + ':xxxx'
    end
  end

  def sanitize_path(path)
    # Convert path to cache-safe key
    path.gsub(/[^a-zA-Z0-9\-_\/]/, '_')
  end

  def self.visitor_count
    Rails.cache.fetch('visitor_count', expires_in: 1.year) { 0 }
  end

  def self.total_page_views
    Rails.cache.fetch('total_page_views', expires_in: 1.year) { 0 }
  end

  def self.recent_visitors
    Rails.cache.fetch('recent_visitors', expires_in: 30.days) { [] }
  end

  def self.popular_pages
    # Get all page view counts
    all_keys = Rails.cache.instance_variable_get(:@data)&.keys || []
    page_keys = all_keys.select { |key| key.start_with?('page_') }

    pages = page_keys.map do |key|
      path = key.gsub('page_', '').gsub('_', '/')
      count = Rails.cache.read(key) || 0
      { path: path, views: count }
    end

    pages.sort_by { |p| -p[:views] }.first(10)
  rescue
    []
  end
end
