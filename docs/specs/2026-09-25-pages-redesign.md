# Pages redesign: background, Projects, Photos, Home viewer (spec, 2026-09-25)

ELI5: four small pieces, built one at a time, a commit after each. Agreed with Julian in chat on
2026-09-25. Before any of it: the checker runs on the earlier uncommitted work and that work is
committed.

## 1 · The waves on every page
**Goal:** the seigaiha background looks right on every public page, not only Home.

- The `<canvas data-controller="seigaiha">` moves from `pages/home.html.erb` into
  `layouts/application.html.erb`. `.home-pattern` is renamed `.site-pattern` and moves from
  `pages/_home.scss` into a component file.
- **Home:** unchanged (alpha 0.07, push 12).
- **Inner pages (Projects, Photos index, Blog, Events, project and post pages):** a quieter setting through
  the controller's existing values (about alpha 0.04, push 8). No new JavaScript.
- **No waves:** `/admin`, and the single-photo page (`photos/show`), which stays pure black.
  Today its black backdrop is a fixed `::before` at `z-index: -1`, which would sit *under* the
  canvas, so the canvas must be left out of that page, not only covered.
- Solid white page boxes that hide the waves become transparent. Blocks of body text keep a soft
  cream backing so they stay readable.

**Done when:** each public route shows the waves (Home strong, others faint); the photo page and
`/admin` show none; a Turbo round trip leaves one canvas and no leaked listeners.

## 2 · Projects page
**Goal:** Menyu leads; the rest is grouped by era and sorted by date.

- **Data:** a new `projects.started_on` column (date; only the month is shown, e.g. "Jun 2026").
  Migration written by Claude, **run by Julian**. `showcase:load` fills it in for every project
  (from `db/showcase/projects.yml`).
- **Order on the page:**
  1. **Hero: Menyu.** A large card in its phone frame (the same partials as Home).
     `projects/index` today picks the hero by searching for "alturaflow"; that becomes Menyu.
  2. **Work · Earlier · Bootcamp**: the existing `section` field. Newest `started_on` first inside
     each, and the hero is not repeated. An empty section is not shown.
- **Cards:** Home's `.slide-card` look with the device frames, plus the month and year. The
  description reveals on hover (tap on phones), which replaces the mid-word cut ("…has bee…").
  The tag row shows the first three tags as plain text, with no bare "+16" pill.
- The H1 turns burgundy like Home's.
- Structured data (JSON-LD) keeps listing every project.

**Dates to fill** (from `notes/project-catalog.md`; the three marked Julian were confirmed by him):

| Project | started_on | Source |
|---|---|---|
| Menyu | Jun 2026 | first commit 2026-06-15 |
| Sollo | Jun 2026 | first commit 2026-06-05 |
| MyTap | Sep 2026 | 2026-09-14 |
| imagebank-reader | Sep 2026 | 2026-09-13 |
| YS Club | Sep 2026 | ys-ski 2026-09-17 |
| CS12 Skincare | Jul 2026 | Julian (the pitch mockup, first commit 2026-07-21) |
| AlturaFlow | Jun 2025 | Julian |
| Resume Auto-Fill Chrome Extension | Jun 2025 | 2025-06-23 |
| Portfolio website | Jun 2025 | 2025-06-17 |
| Tokyo Turntable | May 2025 | 2025-05-26 |
| レンtool | May 2025 | bootcamp, May–Jun 2025 |
| Rails-watch-list | May 2025 | Julian |

**Done when:** `/projects` shows Menyu first, then the three eras newest first, each card dated;
no card text is cut mid-word; it renders at 320px.

## 3 · Photos page: a contact sheet per place
**Goal:** each place reads like one roll of film. Its contact sheet sits on top and the full
photos run underneath.

- The place pills stay. Each one picks a roll (`PhotosController#index` already always picks one).
- **Top: the contact sheet.** Black film strips with sprocket holes (a CSS pattern, no images),
  small 3:2 frames, a frame number under each, and the place name and frame count printed on the
  film edge ("HONG KONG · 116"). It holds every photo of that place, oldest upload first. That is
  upload order, not shot order: there is no shot date in the data.
- **Below: the full photos**, large, one after another, loaded only as you scroll near them
  (`loading="lazy"`). Each keeps its `id="photo-<id>"` so the photo page's close button still
  lands on the right spot.
- **Tap a frame** → smooth-scroll to that full photo (instant under reduced motion). **Tap a full
  photo** → the photo page, as today.
- Photo protection (no drag, no right-click save) stays on both the frames and the full photos.
- Empty states stay as they are.

**Done when:** each place shows its own sheet; tapping frame N lands on photo N; the page
stays quick with Hong Kong's 116 photos; it works by touch at 320px.

## 4 · Home photo viewer matches the photo page
**Goal:** a photo opened from Home looks like one opened on `/photos`: a blacked-out page, the
white-framed photo, and the photo page's quiet white X, not the big burgundy circle.

- **First, find out why** Home's modal isn't black. Its styles say black and are imported
  (`components/_photo_modal.scss`), so the cause needs a look in the browser before any fix.
- Make the modal reuse the photo page's frame and `.btn-close-photo` styles rather than its own
  copies, and delete the copies.
- Left and right arrows (and the arrow keys) step through the featured photos, as on the photo page.
- Escape and the X close it, and focus goes back to the photo you clicked.

**Done when:** side by side, Home's viewer and `/photos/:id` look the same; closing returns to
Home where you were.

## Checks for every piece
Rubocop on touched Ruby, the boot check, and the doc guards (`docs/dev.md`). Open each changed
route in Chrome at desktop width and a cropped phone width, with no console errors and a Turbo
round trip. One independent checker at the end (`workers/checker.md`). Docs that the change makes
false are fixed in place (`frontend.md`, `styling.md`, `architecture.md`, `status.md`).

## Not in scope
Blog and Events card redesign (still in `status.md`), a real shot date for photos, an "All"
photos roll, and deploying.
