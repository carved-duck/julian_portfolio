# Frontend — Turbo, Stimulus, the carousel

ELI5: Turbo swaps pages without a full reload, so code that only runs "when the page loads" stops
running after the first click. Almost every frontend bug in this repo is that. Checked 2026-09-25.

## The Turbo rule
Turbo does not fire `DOMContentLoaded` on navigation. Anything that must run on every visit listens
for `turbo:load` (and `DOMContentLoaded` if it also has to run on the first hard load).

## The carousel rule
The featured-photos carousel is two carousels in one partial
(`app/views/photos/_featured_carousel.html.erb`): a custom transform-based one on desktop and a
Bootstrap carousel on mobile. It binds both `DOMContentLoaded` and `turbo:load`, and **disposes the
existing Bootstrap instance before making a new one**:
`bootstrap.Carousel.getInstance(el)?.dispose()`. Re-creating without disposing stacks instances;
that was the root of the old "carousel broken on mobile" reports.

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
