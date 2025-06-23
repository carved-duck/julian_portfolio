# Spam Protection System

This document outlines the multi-layered spam protection system implemented for the contact form.

## Protection Layers

### 1. **User Agent Detection**
- Blocks known bot user agents (python-requests, curl, wget, scrapy, etc.)
- Prevents automated script submissions

### 2. **Multiple Honeypot Fields**
- **website**: Positioned off-screen, looks like a real field
- **url**: Hidden with CSS `display: none`
- **company_website**: Hidden with opacity and positioning
- **phone_number**: Hidden with Bootstrap's `d-none` class

Different hiding techniques make it harder for smart bots to detect all traps.

### 3. **Rate Limiting**
- Maximum 3 submissions per IP address per hour
- Automatically cleans old entries to prevent memory bloat
- Configurable in `config/initializers/spam_protection.rb`

### 4. **Time-Based Protection**
- **Server-side**: Minimum 3 seconds form fill time
- **Client-side**: Minimum 2 seconds interaction time
- Prevents instant bot submissions

### 5. **Human Interaction Tracking**
- Tracks keyboard events, focus events, and paste events
- Ensures user actually interacted with form fields
- Blocks programmatic submissions without human interaction

### 6. **Content Analysis**
- **Spam keyword detection**: Configurable list of common spam terms
- **URL counting**: Blocks messages with multiple URLs
- **Message length**: Minimum 10 characters required
- **Email pattern analysis**: Detects suspicious email formats

### 7. **Security Headers**
- CSRF protection enabled
- X-Frame-Options: DENY (prevents clickjacking)
- X-Content-Type-Options: nosniff
- X-XSS-Protection: enabled
- Cache-Control: no-cache (prevents cached form submissions)

### 8. **robots.txt Protection**
- Disallows `/contact` endpoint for all crawlers
- Blocks known spam bots (SemrushBot, AhrefsBot, etc.)
- Allows legitimate search engines for main content only

## Configuration

Edit `config/initializers/spam_protection.rb` to:
- Add/remove spam keywords
- Adjust rate limits
- Modify email patterns
- Change timing thresholds

## Spam Response Strategy

When spam is detected:
- Returns "success" message to user (doesn't reveal detection)
- Logs detailed information for analysis
- Doesn't send actual email
- Prevents spam feedback loops

## Monitoring

Check your Rails logs for spam detection events:
```
tail -f log/development.log | grep "Spam detected\|Rate limited\|Suspicious"
```

## Common Spam Patterns Detected

Based on your spam examples, this system catches:
1. **SEO/Marketing emails** with keywords like "google ranking", "increase traffic"
2. **Web development spam** with "website design", "affordable cost"
3. **Multiple URL submissions**
4. **Suspicious email patterns** like `firstname.lastname@gmail.com`
5. **Fast bot submissions** without human interaction

## Legitimate User Impact

- Real users won't notice any changes
- Form still works normally for humans
- No additional steps required
- Performance impact is minimal

## Next Steps

Consider adding:
1. **Redis** for rate limiting in production
2. **IP-based geoblocking** for known spam regions
3. **reCAPTCHA** for additional protection
4. **Email verification** for high-risk submissions
