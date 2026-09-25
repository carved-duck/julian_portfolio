# What's open right now (Layer 4)

ELI5: the short list of what's waiting. One line per item, a pointer to the detail, no history.
When something closes, delete its line here in the same session (the commit message is the record).

## Live
- Heroku still runs the May projects/photos redesign; everything since is on `master` only.

## Next
- **The site redesign, page by page** (Julian, 2026-09-25). Burgundy is now Bootstrap's primary.
  Agree each page's changes before building (`../workers/workflow.md` step 2).
  - **Built locally (not deployed):** Home, waves on every page, Projects (Menyu hero, eras by
    date), Photos contact sheet, Home viewer matching the photo page
    (`specs/2026-09-25-pages-redesign*.md`). Julian's eye check still owed: Claude's Chrome tab
    was hidden, so motion, smooth scroll and the viewer's final paint were checked by measurement.
  - **Still owed by Julian:** phone screenshots for Menyu (home screen) and Sollo (today cropped
    from App Store tiles) · optionally a photo for the imagebank-reader card · a MyTap screenshot
    if the app's colours changed (today's is sollo.my/tap cropped to phone width).
  - **To go live (Julian's go):** push, deploy, `heroku run rails db:migrate`, then
    `heroku run rails showcase:load` with `FORCE_IMAGES=1` (new MyTap icon). There's no release
    phase, so `/projects` errors between the deploy and the migrate: run them back to back.
  - **Home viewer on phones:** the arrows are hidden under 768px and there's no swipe, so a phone
    sees one photo per open. Add swipe (the photo page has it) if wanted.
  - **Design review findings still open after that** (`specs/2026-09-25-design-review.md`): Events
    and Blog keep the old flat cards · Blog's empty state is a dead end: point it at Photos and
    Projects.

## Waiting on Julian
- **Broken admin scaffold tests:** repair them, or delete them (`dev.md` § Commands, "Test suite
  state"). Until tests run, event capacity changes have no automated check.
- **Event SEO wording:** `ApplicationHelper` describes events as "photography workshops, tech
  meetups"; the real events are casual BBQs and meetups. Pick the wording.
- **Phone-width walk of the May redesign** (projects, photos, home): only checked at desktop width
  and in markup so far.
- **Writer pass on the redesign's strings** (never done): the "Featured project" eyebrow, "More
  about it", "Interested in working together?", and the photos empty-state copy. The May
  writer audit (~30 copy proposals + 4 copy bugs) was lost with the chat; redo it with the redesign.
- **Dependency upgrades** (Rails 7.1 → 8, Puma 6 → 8, Ruby 3.3 → 3.4): proposed in May, one PR per
  big jump. The written plan was lost with the chat; redo it when wanted.

## Ideas (not a go)
- An "All" photo filter: `PhotosController#index` always picks a category; allowing a blank one
  (→ `Photo.in_roll_order`) is about two lines, but a 331-frame contact sheet would need paging.
- Auto-screenshot a project's live URL for its image (a screenshot service or headless capture).

## Known bugs (small, unfixed)
- `photo_protection_controller.js` `disconnect()` removes fresh `.bind(this)` copies, so nothing is
  removed: listeners leak across Turbo visits (`frontend.md` § Stimulus).
- `photo_navigation_controller.js` never removes its `turbo:frame-load` listener.
- `ApplicationHelper#body_class` keys on `'submissions'`, but the controller is `events`, so
  `events-page` is never set.
- `ApplicationMailer` default `from` is still `from@example.com`.
- The contact rate limit resets on every dyno restart (`architecture.md` § Contact form and email).
- Dead code: `Project#display_tags_inline` (no callers); `bin/docker-entrypoint` and
  `.dockerignore` (the Dockerfile is gone).
- `projects/show` "More Projects" loads images one query each (3 rows; minor).
