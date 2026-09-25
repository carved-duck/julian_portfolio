# Architecture — stack, data model, auth, images, email

ELI5: what the app is built from and how its pieces behave. Checked against the code 2026-09-25.
When the code and this file disagree, the code wins: fix this file in place.

## Stack
- Ruby 3.3.5 (`.ruby-version`), Rails 7.1.5, PostgreSQL, Puma.
- Hotwire (Turbo + Stimulus) through **importmap-rails**. No JS build step, no `node_modules`.
  Pins live in `config/importmap.rb`.
- Sprockets asset pipeline, SCSS via `sassc-rails`. Bootstrap 5.3, `simple_form`,
  `font-awesome-sass`.
- Active Storage backed by **Cloudinary** in development and production; test uses Disk
  (`config/storage.yml`, `config/environments/*.rb`).
- Jobs run on the `:async` adapter: in-process, lost on restart. Don't treat a queued job as durable.
- Deploy: **Heroku** (`heroku` git remote). Buildpacks, not Docker. Postgres via `DATABASE_URL`.
- The `geocoder` gem is installed but has no config and no caller (see Open questions).

## Domain model (`app/models/`)
- **Project** — `has_one_attached :featured_image`, `has_many_attached :screenshots`,
  `has_one_attached :icon`. `frame` is how its card shows the image (`browser`, `phone`,
  `terminal`); `section` is where it sits on the Projects page (`work`, `earlier`, `bootcamp`).
  The admin form offers `started_on` but not frame, section, icon or screenshots: only `showcase:load`
  (`ShowcaseLoader`, data in `db/showcase/projects.yml`) sets them. Tags are one comma-separated string;
  `tag_list` / `tag_list=` split and join it, `categorized_tags` buckets them (Core Stack,
  Frontend, Services, Tools & Libraries, Features). Scopes `featured`, `recent`, `by_start`
  (newest `started_on` first, undated last). `started_on` is when Julian began it; only the month
  is shown. The Projects page leads with `HERO_TITLE` (Menyu, else the newest project), then one
  grid per section in `SECTIONS` order. `has_links?` checks for a GitHub or live URL.
- **BlogPost** — builds a unique `slug` before save (adds a counter on collision); `to_param`
  returns it, so URLs use the slug. `published` = `published_at` present; `recent` orders by
  `published_at` desc.
- **Photo** — `has_one_attached :image`, a `category`, optional `location`. One featured photo
  per category: `feature!` runs in a transaction and unfeatures the others. Scopes
  `by_category`, `recent`, `featured`, `in_roll_order` (oldest upload first: the Photos page's
  contact sheet and the photo page's next/previous both use it; there is no shot date).
- **Event** — `has_many :attendees`. `event_type` is `"bbq"` or `"normal"`. Scopes `active`,
  `bbq_events`, `normal_events`.
  - BBQ events use a "pending zone" model in 10-person table steps (`next_table_threshold`,
    `in_pending_zone?`, `spots_until_next_table`, `capacity_warning_message`), keyed off
    `target_capacity`. `at_capacity?` is always false for BBQ events.
  - Normal events use `target_capacity` with `at_capacity?` and `capacity_full_message`.
  - Bringing categories apply to **normal events only**: `requires_bringing_field?` is
    `normal_event? && enable_bringing_categories?`. Guests pick from `BRINGING_CATEGORIES`
    (Drinks, Desserts, Snacks, Appetizers, Main Dish); `bringing_breakdown` totals them.
- **Attendee** — `belongs_to :event`. Needs `name` and `instagram_handle`. `bringing` is required
  only when the event `requires_bringing_field?`; `bringing_other` is a virtual attribute for "Other".

## Auth boundary
- **Public area:** no login. `ApplicationController` counts visitors with a cache fingerprint
  (IP + user agent + Accept-Language, deduped over 24 hours) and skips bots and `/admin`.
- **Admin (`/admin`):** HTTP Basic Auth only, in `app/controllers/admin/base_controller.rb`, against
  `ENV['ADMIN_USERNAME']` / `ENV['ADMIN_PASSWORD']`. Stateless, single user, no sessions, no roles.
  Every admin controller inherits `Admin::BaseController`.

## Images
- `ImageCompressionService.compress` shrinks any file over 10MB: convert to JPEG, strip EXIF,
  progressive, step quality from 95 down to 30 until it is at or under 9.8MB.
- Callers: `BulkPhotoUploadJob` (turns uploaded blobs into Photo records) and the admin photo
  create/update actions (`app/controllers/admin/photos_controller.rb`).
- Public pages eager-load attachments (`with_attached_*`) to avoid one query per image.

## Contact form and email
- Spam defenses are layered; full notes in `spam-protection.md`. Two timing checks, both on
  purpose and both enforced by the server in `PagesController`: at least 10 seconds from
  `form_start_time`, and at least 2 seconds of `client_timing` reported by the Stimulus controller.
- The rate limit (2 per IP per hour) is held in a class variable in `PagesController`: per process,
  reset on every dyno restart.
- Mail goes out over Gmail SMTP. `ContactMailer` sends to `julian@trendrider.io` from
  `noreply@julianportfolio.com`. `ApplicationMailer` still has the default `from@example.com`.

## Environment
Env vars: `CLOUDINARY_URL`, `ADMIN_USERNAME`, `ADMIN_PASSWORD`, `GMAIL_USERNAME`,
`GMAIL_APP_PASSWORD`, `DOMAIN`, `DATABASE_URL`, plus the standard `RAILS_*`, `PORT`,
`WEB_CONCURRENCY`. The GA4 measurement ID is **not** an env var: it is in Rails encrypted
credentials as `google_analytics_id`, read in the layout (production only).

## SEO
`config/initializers/seo_config.rb` (`SeoConfig`) and the `ApplicationHelper` meta/JSON-LD
helpers. Full notes: `seo.md`.

## Open questions (flag, don't act on)
- **`geocoder`** — installed, unused.
