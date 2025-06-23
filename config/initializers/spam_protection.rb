# Spam Protection Configuration
module SpamProtection
  # Keywords commonly found in spam messages
  SPAM_KEYWORDS = [
    'seo', 'search engine optimization', 'first page', 'top ranking', 'google ranking',
    'increase traffic', 'web development', 'website design', 'digital marketing',
    'social media marketing', 'click here', 'visit us at', 'learn more',
    'affordable cost', 'very affordable', 'best price', 'guaranteed result',
    'targeted traffic', 'boost your sales', 'increase your revenue',
    'potential clients', 'leaving your site', 'build a new website',
    'custom websites', 'small businesses', 'startups', 'quality websites',
    'mobile-friendly', 'loads fast', 'easy to manage', 'secure and optimized',
    'ongoing support', 'without spending a lot', 'fits your budget'
  ].freeze

  # Suspicious email patterns
  SUSPICIOUS_EMAIL_PATTERNS = [
    /\d{5,}/, # Email with 5+ consecutive digits
    /^[a-z]+\.[a-z]+@gmail\.com$/, # Simple firstname.lastname@gmail.com
    /^[a-z]+\.[a-z]+\.mkt@gmail\.com$/, # Marketing pattern
    /^[a-z]+@[a-z]+inc\.com$/, # Pattern like manshis@vgroupinc.com
    /submissions@.*\.site$/ # Pattern like submissions@searchindex.site
  ].freeze

  # User agents commonly used by spam bots
  BOT_USER_AGENTS = [
    /python-requests/i,
    /curl/i,
    /wget/i,
    /scrapy/i,
    /bot/i,
    /spider/i,
    /crawler/i
  ].freeze

  # Configuration
  MAX_SUBMISSIONS_PER_HOUR = 2
  MIN_FORM_FILL_TIME = 10.seconds
  MIN_MESSAGE_LENGTH = 10
  MAX_SPAM_SCORE = 2
  MAX_URLS_IN_MESSAGE = 1
end
