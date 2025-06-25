class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Add security headers
  before_action :set_security_headers
  # Track unique visitors
  before_action :track_visitor

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

    # Only track if this session hasn't been counted yet
    unless session[:visitor_counted]
      # Get current count and increment
      current_count = Rails.cache.fetch('visitor_count', expires_in: 1.year) { 0 }
      Rails.cache.write('visitor_count', current_count + 1, expires_in: 1.year)

      # Mark this session as counted
      session[:visitor_counted] = true

      # Also track when they visited
      session[:first_visit] = Time.current
    end
  end

  def self.visitor_count
    Rails.cache.fetch('visitor_count', expires_in: 1.year) { 0 }
  end
end
