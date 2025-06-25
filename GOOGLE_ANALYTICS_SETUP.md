# Google Analytics 4 Setup Guide

This guide will help you set up Google Analytics 4 (GA4) for your portfolio with detailed visitor tracking and custom events.

## 🎯 What You'll Get

With this setup, you'll track:
- **Page views** with detailed paths
- **Unique visitors** with better fingerprinting
- **Project interactions** (which projects people view)
- **Contact form engagement** (opens and submissions)
- **External link clicks** (GitHub, live sites)
- **Popular pages** and visitor paths
- **Visitor timing** and engagement metrics
- **Geographic and device data**

## 📊 Step 1: Create Google Analytics Account

1. Go to [Google Analytics](https://analytics.google.com/)
2. Click "Start measuring"
3. Create an account name (e.g., "Julian Portfolio")
4. Choose "Web" as the platform
5. Enter your website details:
   - **Website Name**: Julian Schoenfeld Portfolio
   - **Website URL**: https://julianschoenfeld.com
   - **Industry**: Computers and Electronics
   - **Time Zone**: Your local timezone

## 🔑 Step 2: Get Your Measurement ID

1. After creating the property, you'll see your **Measurement ID** (format: G-XXXXXXXXXX)
2. Copy this ID - you'll need it for the next step

## 🔐 Step 3: Add Measurement ID to Heroku

You need to securely store your Google Analytics ID in your Rails credentials:

### Option A: Using Rails Credentials (Recommended)

```bash
# On your local machine
cd /Users/jju/code/carved-duck/julian-portfolio
EDITOR="code --wait" rails credentials:edit
```

Add this line to the credentials file:
```yaml
google_analytics_id: G-XXXXXXXXXX
```

Save and close the file, then deploy to Heroku:
```bash
git add config/credentials.yml.enc
git commit -m "Add Google Analytics credentials"
git push heroku master
```

### Option B: Using Environment Variables

If you prefer environment variables, add this to your Heroku app:

```bash
heroku config:set GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX
```

Then update `app/views/layouts/application.html.erb` to use:
```erb
<%= ENV['GOOGLE_ANALYTICS_ID'] %>
```
instead of
```erb
<%= Rails.application.credentials.google_analytics_id %>
```

## 🎛️ Step 4: Configure Custom Events in GA4

In Google Analytics, set up custom events to track portfolio-specific interactions:

### 4.1 Create Custom Definitions

1. In GA4, go to **Admin** → **Custom Definitions** → **Custom Dimensions**
2. Click **Create custom dimension**
3. Add these custom dimensions:

| Dimension Name | Event Parameter | Scope |
|---------------|-----------------|-------|
| Visitor Type | custom_definition_1 | Event |
| Project Name | project_name | Event |
| Link URL | link_url | Event |
| Link Text | link_text | Event |

### 4.2 Create Custom Events

Go to **Admin** → **Events** → **Create Event** and add:

1. **Project Views**
   - Event name: `view_project`
   - Conditions: `event_name = view_project`

2. **Contact Form Opens**
   - Event name: `contact_form_open`
   - Conditions: `event_name = contact_form_open`

3. **Contact Form Submissions**
   - Event name: `contact_form_submit`
   - Conditions: `event_name = contact_form_submit`

4. **External Link Clicks**
   - Event name: `click_external_link`
   - Conditions: `event_name = click_external_link`

## 📈 Step 5: Set Up Goals and Conversions

### 5.1 Mark Events as Conversions

1. Go to **Admin** → **Conversions**
2. Toggle these events as conversions:
   - `contact_form_submit` (main goal)
   - `click_external_link` (secondary goal)
   - `view_project` (engagement goal)

### 5.2 Create Audiences

Go to **Admin** → **Audiences** → **Create Audience**:

1. **Engaged Visitors**: Users who viewed 3+ pages
2. **Project Browsers**: Users who triggered `view_project` events
3. **Potential Clients**: Users who opened contact form

## 🔍 Step 6: Enhanced Internal Analytics

Your admin dashboard now shows:

### Real-time Metrics
- **Unique Visitors**: 24-hour unique fingerprints (IP + User Agent + Language)
- **Page Views**: Total page view count
- **Today's Visitors**: Visitors in the last 24 hours
- **Engagement**: Average pages per visitor

### Detailed Tables
- **Popular Pages**: Most visited pages with view counts
- **Recent Visitors**: Last 10 visitors with anonymized IPs, timestamps, landing pages, and browser info

### Bot Protection
- Automatic filtering of bot traffic
- User agent detection for crawlers
- Honeypot protection integration

## 📊 Step 7: Understanding Your Data

### Internal Analytics (Admin Dashboard)
- **Immediate data**: Updates in real-time
- **Privacy-focused**: IPs are anonymized
- **Simple metrics**: Focus on essential KPIs
- **No external dependencies**: Works even if GA4 is down

### Google Analytics 4
- **Detailed insights**: Demographics, devices, traffic sources
- **Advanced reporting**: Custom reports and funnels
- **Machine learning**: Predictive metrics and insights
- **Industry benchmarks**: Compare your site to others

## 🚀 Step 8: Monitoring and Optimization

### Daily Checks (Admin Dashboard)
- Visitor count trends
- Popular pages performance
- Contact form conversion rate

### Weekly Analysis (Google Analytics)
- Traffic source breakdown
- User journey analysis
- Device and browser trends
- Geographic visitor distribution

### Monthly Reviews
- Goal completion rates
- Audience growth trends
- Content performance analysis
- Technical performance metrics

## 🔧 Troubleshooting

### Common Issues

1. **No data showing in GA4**
   - Check Measurement ID is correct
   - Verify script loads only in production
   - Allow 24-48 hours for data to appear

2. **Events not tracking**
   - Check browser console for JavaScript errors
   - Verify `gtag` function is available
   - Test events in GA4 DebugView

3. **High bounce rate**
   - Ensure page load times are fast
   - Check mobile responsiveness
   - Verify internal links work correctly

### Debug Mode

To test events locally, temporarily change this in `application.html.erb`:
```erb
<% if Rails.env.production? || Rails.env.development? %>
```

Then check the browser console for `gtag` calls.

## 📚 Additional Resources

- [Google Analytics 4 Documentation](https://support.google.com/analytics/answer/10089681)
- [GA4 Event Tracking Guide](https://support.google.com/analytics/answer/9267735)
- [Custom Dimensions Setup](https://support.google.com/analytics/answer/10075209)

## 🎉 What's Next?

After setup, you'll have:
1. ✅ Real-time visitor tracking with enhanced accuracy
2. ✅ Detailed analytics dashboard in your admin panel
3. ✅ Professional Google Analytics setup
4. ✅ Custom event tracking for portfolio interactions
5. ✅ Bot protection and spam filtering
6. ✅ Privacy-compliant visitor analytics

Your portfolio now has enterprise-level analytics that will help you understand your visitors and optimize your content for better engagement!
