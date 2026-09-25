# What's open right now (Layer 4)

ELI5: the short list of what's waiting. One line per item, a pointer to the detail, no history.
When something closes, delete its line here in the same session (the commit message is the record).

## Live
- `master` carries the projects/photos redesign and the May health pass (committed 2026-09-25).
  Not yet deployed to Heroku unless Julian has pushed `heroku` since.

## Next
- **The site redesign** (Julian, 2026-09-25). Plan not written yet: agree it first
  (`../workers/workflow.md` step 2).

## Waiting on Julian
- **Local database.** Point dev at a local Postgres: fix the placeholder names in
  `config/database.yml`, drop `DATABASE_URL` from `.env`, create the DB, load a copy of the data
  (`heroku pg:pull`). Julian runs DB tooling. Until then, see `dev.md` Trap 2.
- **Broken admin scaffold tests:** repair them, or delete them (`dev.md` § Commands, "Test suite
  state"). Until tests run, event capacity changes have no automated check.
- **Projects hero:** no AlturaFlow project exists in prod, so the hero falls back to the first
  featured project. Add it, or mark the project you want `featured`.
- **Event SEO wording:** `ApplicationHelper` describes events as "photography workshops, tech
  meetups"; the real events are casual BBQs and meetups. Pick the wording.
- **Phone-width walk of the May redesign** (projects, photos, home): only checked at desktop width
  and in markup so far.
- **Writer pass on the May redesign's new strings** (never done): the "Featured Project" eyebrow,
  "More Projects", "Interested in working together?", and the photos empty-state copy. The May
  writer audit (~30 copy proposals + 4 copy bugs) was lost with the chat; redo it with the redesign.
- **Dependency upgrades** (Rails 7.1 → 8, Puma 6 → 8, Ruby 3.3 → 3.4): proposed in May, one PR per
  big jump. The written plan was lost with the chat; redo it when wanted.

## Ideas (not a go)
- An "All" photo filter: `PhotosController#index` always picks a category; allowing a blank one
  (→ `Photo.recent`) is about two lines, then the pill comes back.
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
