# Julian Schoenfeld Portfolio

A modern, full-stack portfolio website built with Ruby on Rails, featuring project showcases, blog posts, event management, and comprehensive analytics.

## 🌟 Features

### Core Functionality
- **Project Portfolio** - Showcase web development projects with categorized tags, live demos, and GitHub links
- **Photography Gallery** - Display photography work with Cloudinary integration
- **Blog System** - Write and publish blog posts with SEO optimization
- **Event Management** - Create events and manage attendee signups
- **Contact System** - Multi-layer spam-protected contact form

### Advanced Systems
- **Enterprise Analytics** - Enhanced visitor tracking with IP fingerprinting and Google Analytics 4
- **SEO Optimization** - Dynamic sitemaps, structured data, meta tags, and Search Console integration
- **Spam Protection** - Multi-layer protection with honeypots, rate limiting, and content analysis
- **Admin Dashboard** - Comprehensive content management and visitor analytics

## 🚀 Live Site

**Production:** [https://julian-portfolio-1ce15f30ff1c.herokuapp.com/](https://julian-portfolio-1ce15f30ff1c.herokuapp.com/)

## 🛠️ Tech Stack

- **Backend:** Ruby on Rails 7.1
- **Frontend:** Bootstrap 5, Stimulus, SCSS
- **Database:** PostgreSQL (Heroku Postgres)
- **Image Storage:** Cloudinary
- **Deployment:** Heroku
- **Analytics:** Google Analytics 4 + Custom Internal Tracking

## 📊 Analytics & Monitoring

The portfolio includes two levels of analytics:

### Internal Analytics (Real-time)
- Enhanced visitor tracking with IP + User Agent fingerprinting
- Popular pages and visitor journey analysis
- Bot detection and spam filtering
- Privacy-compliant data collection

### Google Analytics 4
- Comprehensive visitor demographics and behavior
- Custom event tracking (project views, contact forms, external links)
- Geographic and device analysis
- Conversion funnel monitoring

## 🛡️ Security Features

### Spam Protection
Multi-layer contact form protection including:
- Multiple honeypot fields with different hiding techniques
- Rate limiting (1 submission per IP per hour)
- User agent and bot detection
- Content analysis and keyword filtering
- Human interaction tracking

**See:** [SPAM_PROTECTION.md](SPAM_PROTECTION.md) for detailed configuration

### Security Headers
- CSRF protection
- XSS protection
- Clickjacking prevention
- Content type sniffing protection

## 🔍 SEO Optimization

Comprehensive SEO implementation:
- Dynamic XML sitemaps with auto-updating content
- Structured data (Schema.org) for projects, blog posts, and events
- Open Graph and Twitter Card meta tags
- Breadcrumb navigation with structured data
- Canonical URLs and internal linking

**See:** [SEO_IMPROVEMENTS.md](SEO_IMPROVEMENTS.md) for setup instructions

## 🏗️ Development Setup

### Prerequisites
- Ruby 3.3.5
- Rails 7.1
- PostgreSQL
- Node.js (for asset compilation)

### Local Development
```bash
# Clone the repository
git clone [repository-url]
cd julian-portfolio

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails server
```

### Environment Variables
Required for full functionality:
- `CLOUDINARY_URL` - Image storage and optimization
- `GOOGLE_ANALYTICS_ID` - Analytics tracking (production only)

## 📁 Project Structure

```
app/
├── controllers/
│   ├── admin/           # Admin panel controllers
│   ├── application_controller.rb  # Enhanced visitor tracking
│   └── pages_controller.rb        # Spam-protected contact form
├── models/              # Project, Photo, BlogPost, Event, Attendee
├── views/
│   ├── admin/          # Admin dashboard and management
│   ├── layouts/        # Main layout with analytics integration
│   └── shared/         # Contact modal and navigation
├── javascript/
│   └── controllers/    # Stimulus controllers with GA4 tracking
└── assets/
    └── stylesheets/    # SCSS with Bootstrap customization
```

## 🎯 Key Features Explained

### Enhanced Visitor Tracking
- **Unique Identification:** IP + User Agent + Language fingerprinting
- **24-hour Windows:** Prevents double-counting same visitor
- **Bot Filtering:** Excludes crawlers and automated traffic
- **Privacy Compliant:** IP anonymization and secure storage

### Project Categorization
- **Smart Tag Grouping:** Automatically categorizes technologies (Core Stack, Frontend, Services, Features)
- **Inline Display:** Shows primary tags with "+X more" for cards
- **Detailed View:** Full categorized display on project pages

### Contact Form Protection
- **4 Honeypot Fields:** Different hiding techniques to catch various bots
- **Timing Analysis:** Minimum form fill time requirements
- **Content Filtering:** Spam keyword and pattern detection
- **Rate Limiting:** IP-based submission throttling

## 📈 Analytics Dashboard

Access the admin dashboard at `/admin` to view:
- Real-time visitor counts and page views
- Popular pages with view statistics
- Recent visitors with anonymized data
- Content management for all portfolio sections

## 🚀 Deployment

The application is configured for Heroku deployment with:
- Automatic asset precompilation
- Production-optimized caching
- Environment-based configuration
- Secure credential management

## 📝 Content Management

### Adding Projects
1. Access `/admin/projects`
2. Upload featured image via Cloudinary
3. Add categorized tags (automatically grouped)
4. Include live URL and GitHub repository links

### SEO Optimization
- Page titles and descriptions are automatically generated
- Sitemap updates automatically with new content
- Structured data is embedded for search engines

## 🤝 Contributing

This is a personal portfolio project, but the architecture and features can serve as a reference for similar Rails applications.

## 📄 License

Personal portfolio project - all rights reserved.

---

**Built with ❤️ using Ruby on Rails**
