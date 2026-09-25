# Frontend — Turbo, Stimulus, the slider

ELI5: Turbo swaps pages without a full reload, so code that only runs "when the page loads" stops
running after the first click. Almost every frontend bug in this repo is that. Checked 2026-09-25.

## The Turbo rule
Turbo does not fire `DOMContentLoaded` on navigation. Anything that must run on every visit listens
for `turbo:load` (and `DOMContentLoaded` if it also has to run on the first hard load).

## Rows of cards: the slider, not a carousel
There is no Bootstrap carousel in the app any more (removed 2026-09-25). The old home carousel was
two carousels in one partial (a custom one on desktop, Bootstrap's on mobile) re-created on every
`turbo:load`, and that was the root of the recurring "carousel broken on mobile" reports.

A sideways row of cards now uses `pages/_slider.html.erb` + `slider_controller.js`: the row is a
plain horizontal scroll container with CSS scroll-snap, so swipe, trackpad and keyboard scrolling
come from the browser, and the arrows only call `scrollBy`. Nothing to re-create on Turbo visits.
If a Bootstrap carousel is ever added back, dispose the old instance before making a new one:
`bootstrap.Carousel.getInstance(el)?.dispose()`.

## Home page pieces
- `seigaiha_controller.js` — the site background: seigaiha (青海波) waves on a `<canvas>` that the
  layout renders via `ApplicationHelper#site_pattern_tag`, at `z-index: -1`. Never give `<main>` a
  z-index to lift content over it instead: that traps every modal rendered inside `<main>` (the
  photo viewer, the events pending modal) beneath Bootstrap's backdrop. Burgundy at 7% on Home, 4% with a smaller
  push on inner pages, none on the black photo page or in `/admin`. Near the mouse the scales slide outward and turn, like leaves pushed aside; a
  tap sends a ripple; still pattern under reduced motion. It only runs animation frames while
  something is moving; a resting mouse costs nothing.
- `showcase_controller.js` — the two doors (Featured photos, Featured dev work). Hover opens a
  panel on mouse devices; click/tap/Enter opens it everywhere. Both panels share one grid cell, so
  swapping them never moves the page.
- Photos page (`photos/index`): a contact sheet of the chosen place's frames, then the same roll as
  a square grid (`#photo-<id>` on each tile, so the photo page's close link lands on it). Every
  frame and tile opens the viewer below (`PhotosHelper#photo_viewer_data`); without JS they go to
  the photo's page. Bootstrap's page-wide smooth scroll is off (`$enable-smooth-scroll: false`) so
  Turbo's restore scrolls stay instant. `photo_protection_controller.js` lets taps through on
  `.contact-frame-link` and links to `/photos/…` only.
- `photo_modal_controller.js` — the full-screen photo viewer (`photos/_photo_modal.html.erb`) on Home
  and the Photos page, dressed like the photo page: `.photo-frame`, `.btn-close-photo`,
  `.btn-side-nav`. Arrows, ←/→ and a sideways swipe step through the page's photos (each once, even
  when linked twice) and stop at either end. `_modal.scss` paints every modal cream
  for the contact form, so `_photo_modal.scss` resets `.modal-content` and `.modal-body`. On
  `turbo:before-cache` it closes itself and clears Bootstrap's backdrop, so Back never restores it open.
- Device frames on project cards: `projects/_frame_browser` (the page scrolls itself on hover)
  and `_frame_terminal` fill the card; apps (`frame: "phone"`) get `projects/_feature_phone`, an App
  Store "Today"-style card: icon, name and a short line (`project_tagline`) on the brand colour, with
  `_frame_phone` rising at the right (screens cross-fade on hover when there's more than one).
  CSS only, in `components/_devices.scss`; on touch screens the demos play by themselves, and under
  reduced motion nothing plays. Brand
  colours, browser-bar host and terminal lines come from `ProjectsHelper`.

**Testing through Claude's Chrome tool:** when Julian's Chrome window is in the background the tab
reports `document.visibilityState === "hidden"`, and Chrome runs no animation frames. Smooth
scrolling, scroll events and the wave animation all stall there. It's not a bug; check those by eye.

## Stimulus
- Controllers in `app/javascript/controllers/` auto-register via `eagerLoadControllersFrom`.
- Whatever `connect()` binds (listeners, timers, Bootstrap instances), `disconnect()` removes, or
  it leaks across Turbo cache restores.
- **The pattern to copy:** `contact_form_controller.js` — an `addListener()` helper records every
  listener, and `disconnect()` walks the list. `bulk_upload_controller.js` clears its timers and
  sets a `disconnected` flag so late fetch callbacks do nothing.
- **Don't copy:** removing `this.fn.bind(this)` in `disconnect()`. Each `.bind` makes a new
  function, so the remove matches nothing. `photo_protection_controller.js` does this today (open
  bug in `status.md`).

## Workarounds in `app/javascript/application.js`
- Submit buttons are re-enabled on `turbo:load` (Turbo can leave them disabled).
- Flash messages auto-hide on both load events.

## New JS
No build step: a new library is pinned in `config/importmap.rb`, not installed with npm.
