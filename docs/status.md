# What's open right now (Layer 4)

ELI5: the short list of what's waiting. One line per item, a pointer to the detail, no history.
When something closes, delete its line here in the same session (the commit message is the record).

## Live
- Heroku runs release v78 (`67ebbea`): the 2026-09-25 redesign (Home, waves on every page,
  Projects, project pages, Photos), the 2026-09-26 rewrite of all 12 projects' copy and tags, the
  2026-09-27 home tagline wording, and the 2026-10-28 wind billows (the waves lift like cloth).
  Migrations and `showcase:load` done on production.
- **Deploy steps** (at Julian's go): `git push heroku master`, then straight away
  `heroku run rails db:migrate -a julian-portfolio` if there are migrations (no release phase, so
  pages that need the new columns error until it runs), then
  `heroku run -a julian-portfolio rails showcase:load` if `db/showcase/` changed (add
  `-e FORCE_IMAGES=1` only when its images changed).

## Next
- **The site redesign, page by page** (Julian, 2026-09-25). Burgundy is now Bootstrap's primary.
  Agree each page's changes before building (`../workers/workflow.md` step 2).
  - **Julian's eye check still owed:** Claude's Chrome tab was hidden, so motion and the viewer's
    final paint were checked by measurement.
  - **Home fits one screen + hover lens (on `master`, not deployed):** Julian's eye check owed on a
    real phone (the toolbar case can't be simulated headless). At 320 px wide the cards get
    cramped ("App Store" pill shows "Ap…"); raise the fit floor for narrow phones if that matters.
    Lens tuning is `reach` and `CUTS` (`frontend.md` § Home page pieces). Idea: the lens's small
    waves stay still while a billow lifts the cloth around them; fading the lens during a billow
    would hide it.
  - **Gold light and shadow on billows (on `master`, not deployed):** Julian's eye check owed on the
    live motion (checked by still frames headless); tuning is `LIGHT` in `waves/light.js`.
  - **Wind billows on a real phone:** Julian approved the feel on desktop; still unchecked at phone
    width (place pills, home slider top edge, contact-sheet frames floating near the sprocket
    holes). Tuning is one number each (`frontend.md` § Home page pieces).
  - **Still owed by Julian:** phone screenshots for Menyu (home screen) and Sollo (today cropped
    from App Store tiles) · optionally a photo for the imagebank-reader card · a MyTap screenshot
    if the app's colours changed (today's is sollo.my/tap cropped to phone width).
  - **Design review findings still open** (`specs/2026-09-25-design-review.md`): Events
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
- Dead code: `bin/docker-entrypoint` and `.dockerignore` (the Dockerfile is gone).
- `projects/index.html.erb` builds its JSON-LD by hand with `truncate(strip_tags(...))`, so
  apostrophes land as a literal `&#39;` (it still parses); build it with `to_json` like the show page.
