class PagesController < ApplicationController
  # Rate limiting - store in memory for demo, use Redis in production
  @@submission_times = {}

  def home
    @projects = Project.all
  end

  def contact
    # Multi-layer spam protection
    return render_spam_response if spam_detected?

    contact_params = params.permit(:name, :email, :subject, :message, :form_start_time, :client_timing, :has_interaction)

    # Additional content validation
    return render_spam_response if suspicious_content?(contact_params)

    # Send email using ActionMailer
    ContactMailer.new_contact(contact_params).deliver_now

    render json: { status: 'success', message: 'Message sent successfully! I\'ll get back to you soon.' }
  rescue => e
    Rails.logger.error "Contact form error: #{e.message}"
    render json: { status: 'error', message: 'Failed to send message. Please try again.' }
  end

  private

  def spam_detected?
    # 1. Check user agent for known bots
    return true if bot_user_agent?

    # 2. Honeypot protection - multiple honeypot fields
    return true if honeypot_filled?

    # 3. Rate limiting protection
    return true if rate_limited?

    # 4. Time-based protection (too fast submission)
    return true if submitted_too_fast?

    # 5. Required fields check with unusual patterns
    return true if missing_human_indicators?

    # 6. Check client-side interaction data
    return true if suspicious_client_behavior?

    false
  end

  def bot_user_agent?
    user_agent = request.user_agent.to_s
    if SpamProtection::BOT_USER_AGENTS.any? { |pattern| user_agent.match?(pattern) }
      Rails.logger.warn "Bot user agent detected: #{user_agent}"
      return true
    end
    false
  end

  def honeypot_filled?
    # Check multiple honeypot fields
    honeypot_fields = [:website, :url, :company_website, :phone_number]
    honeypot_fields.any? { |field| params[field].present? }
  end

  def rate_limited?
    client_ip = request.remote_ip
    current_time = Time.current

    # Clean old entries (older than 1 hour)
    @@submission_times[client_ip] ||= []
    @@submission_times[client_ip] = @@submission_times[client_ip].select { |time| time > 1.hour.ago }

    # Check if more than allowed submissions in the last hour
    if @@submission_times[client_ip].length >= SpamProtection::MAX_SUBMISSIONS_PER_HOUR
      Rails.logger.warn "Rate limited IP: #{client_ip}"
      return true
    end

    # Add current submission time
    @@submission_times[client_ip] << current_time
    false
  end

  def submitted_too_fast?
    # If form_start_time is present and submission is too fast
    if params[:form_start_time].present?
      begin
        start_time = Time.at(params[:form_start_time].to_f)
        time_taken = Time.current - start_time
        if time_taken < SpamProtection::MIN_FORM_FILL_TIME
          Rails.logger.warn "Form submitted too fast: #{time_taken}s"
          return true
        end
      rescue ArgumentError
        # Invalid timestamp format
        Rails.logger.warn "Invalid form_start_time: #{params[:form_start_time]}"
        return true
      end
    end
    false
  end

  def suspicious_client_behavior?
    # Check client-side timing if available
    if params[:client_timing].present?
      client_timing = params[:client_timing].to_i
      if client_timing < 2000 # Less than 2 seconds
        Rails.logger.warn "Client-side timing too fast: #{client_timing}ms"
        return true
      end
    end

    # Check if client reported no interaction
    if params[:has_interaction] == 'false'
      Rails.logger.warn "No client-side interaction detected"
      return true
    end

    false
  end

  def missing_human_indicators?
    # Check for required human-like behavior
    return true unless params[:name].present? && params[:email].present? && params[:message].present?

    # Check if message is too short (likely spam)
    return true if params[:message].to_s.length < SpamProtection::MIN_MESSAGE_LENGTH

    # Check for suspicious patterns in name (all numbers, too many special chars)
    name = params[:name].to_s
    return true if name.match?(/^\d+$/) || name.count('^A-Za-z\s') > name.length / 2

    false
  end

  def suspicious_content?(contact_params)
    # Check message content
    message = contact_params[:message].to_s.downcase
    subject = contact_params[:subject].to_s.downcase

    # Count spam keywords using centralized configuration
    spam_score = SpamProtection::SPAM_KEYWORDS.count { |keyword| message.include?(keyword) || subject.include?(keyword) }

    # If more than allowed spam keywords, likely spam
    if spam_score >= SpamProtection::MAX_SPAM_SCORE
      Rails.logger.warn "Suspicious content detected. Spam score: #{spam_score}"
      return true
    end

    # Check for URLs in message (common in spam)
    url_count = message.scan(/https?:\/\/[^\s]+/).length
    if url_count > SpamProtection::MAX_URLS_IN_MESSAGE
      Rails.logger.warn "Multiple URLs detected in message: #{url_count}"
      return true
    end

    # Check for suspicious email patterns using centralized configuration
    email = contact_params[:email].to_s.downcase

    # Only flag if email has suspicious patterns AND other red flags
    if spam_score >= 1 && SpamProtection::SUSPICIOUS_EMAIL_PATTERNS.any? { |pattern| email.match?(pattern) }
      Rails.logger.warn "Suspicious email pattern with spam content: #{email}"
      return true
    end

    false
  end

  def render_spam_response
    Rails.logger.warn "Spam detected from IP: #{request.remote_ip}, User-Agent: #{request.user_agent}"

    # Return success to not give away that we detected spam
    # But don't actually send the email
    render json: { status: 'success', message: 'Message sent successfully! I\'ll get back to you soon.' }
  end
end
