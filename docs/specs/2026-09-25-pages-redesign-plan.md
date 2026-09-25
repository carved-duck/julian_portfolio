# Pages redesign — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** the waves on every page, a Menyu-led Projects page grouped by era and sorted by date,
a contact-sheet Photos page, and a Home photo viewer that matches the photo page.

**Architecture:** Rails 7.1 views, SCSS and Stimulus, no new dependencies. The waves canvas moves
into the layout; a helper decides whether a page gets it, strong or quiet. Projects gain one date
column; the controller picks the hero and groups the rest. The photos index becomes two lists
over the same photos, a thumbnail sheet and the full photos, joined by `#photo-<id>` anchors.

**Tech Stack:** Rails 7.1, Hotwire (Turbo + Stimulus, importmap), Bootstrap 5, SCSS, Cloudinary
via Active Storage, Postgres.

**Spec:** `docs/specs/2026-09-25-pages-redesign.md`

## Global Constraints
- Run Rails as `~/.rbenv/shims/ruby bin/rails …` and rubocop as `~/.rbenv/shims/bundle exec rubocop …`.
- Shell rule: no `cd X && cmd`; absolute paths or `git -C <path>`; prefer Read/Glob over shell `cat`/`find`.
- **Never** run `db:migrate`, `db:drop`, `db:reset`, `db:schema:load`, `db:test:prepare`. Julian runs them.
- The test suite cannot run (no test database; the admin scaffold tests error, `docs/dev.md`). So
  each task's "test" is a read-only `bin/rails runner` check script in the scratchpad, the boot
  check, and walking the route in Chrome. Say which was done.
- Anything that runs on every visit listens for `turbo:load`; Stimulus `disconnect()` undoes
  `connect()` with stored references (`docs/frontend.md`).
- No new rubocop offenses on touched lines (`Layout/LineLength` 120).
- Commits: Conventional Commits, stage files **by name**, **no** `Co-Authored-By` or AI trailer,
  never `--no-verify`. Never stage `AGENTS.md`. Push to `origin` at the end; Heroku only at Julian's go.
- The repo is public: nothing from `notes/` goes into tracked files.
- Waves: Home alpha 0.07 / push 12; inner pages alpha 0.04 / push 8; none on `/admin` or `photos#show`.

## Review Focus
1. **Jumping to frame 90 of Hong Kong while photos 1–89 haven't loaded.** Expected: it lands on
   photo 90 and stays there. Pinned in Task 3 by `width`/`height` on every full photo (all 331
   blobs have them) and `scroll-margin-top` under the navbar.
2. **A project with no `started_on`** (added in admin later). Expected: sorts last in its era, no
   date shown, no error. Pinned in Task 2 by the runner check and the `nulls_last` scope.
3. **No project called Menyu** (renamed or deleted), or no projects at all. Expected: the hero
   falls back to the newest project; zero projects show the existing empty state. Pinned in Task 2.
4. **Turbo round trip Home → Projects → back → Photos.** Expected: exactly one canvas each time,
   strong on Home and quiet elsewhere, no listener pile-up. Pinned in Task 1's browser check.
5. **The viewer's arrows at the first and last featured photo.** Expected: the arrow at the end is
   hidden, not wrapping or erroring; arrow keys do nothing there. Pinned in Task 4.

---

### Task 0: Land tonight's work first

**Files:** whatever the checker flags; then commit everything from the 2026-09-25 session.

- [ ] **Step 1:** Apply the checker's report (2026-09-25). Julian decides which client and partner
  cards are cleared to publish (CS12, YS Club, MyTap/SivanS Lab, AlturaFlow); anything not cleared
  leaves `showcase.rake` and its `db/showcase/` image stays unstaged. Fix W1 (the waves' animation
  loop runs while the mouse rests), W2 (reduced motion misses the phone cross-fade), W3 (close the
  photo modal on `turbo:before-cache`), W5 (rubocop in `showcase.rake`), and the cheap doc
  suggestions. List anything skipped in `claude-talk.md`.
- [ ] **Step 2:** Gates: `~/.rbenv/shims/bundle exec rubocop <touched .rb files>`,
  `~/.rbenv/shims/ruby bin/rails runner scripts/check-boot.rb`, `scripts/check-doc-size.sh`,
  `scripts/check-doc-staleness.sh`. All pass.
- [ ] **Step 3:** Commit by name (every path from `git status` except `AGENTS.md`), including
  this spec and plan. Message: `feat: home redesign with seigaiha, showcase cards and photo viewer`.
  Push to `origin`.

---

### Task 1: The waves on every page

**Files:**
- Modify: `app/helpers/application_helper.rb` (add `site_pattern_tag`)
- Modify: `app/views/layouts/application.html.erb` (render it first inside `<body>`)
- Modify: `app/views/pages/home.html.erb:2` (delete the canvas line)
- Modify: `app/assets/stylesheets/pages/_home.scss:10-21` (delete `.home-pattern`)
- Modify: `app/assets/stylesheets/components/_layout.scss` (add `.site-pattern`, lift `.main-content`)
- Modify: whichever stylesheets Step 5 finds painting opaque page backgrounds

**Interfaces:**
- Produces: `ApplicationHelper#site_pattern_tag` → a `<canvas class="site-pattern">` or `nil`.

- [ ] **Step 1: Add the helper** to `ApplicationHelper`:

```ruby
  # The seigaiha waves behind the page (seigaiha_controller.js): full strength on Home, quieter
  # elsewhere, and none on the black single-photo page or in the admin.
  def site_pattern_tag
    return if controller_path.start_with?("admin/") || (controller_name == "photos" && action_name == "show")

    data = { controller: "seigaiha" }
    data.merge!(seigaiha_alpha_value: 0.04, seigaiha_push_value: 8) unless controller_name == "pages" && action_name == "home"
    tag.canvas(class: "site-pattern", data: data, aria: { hidden: true })
  end
```

- [ ] **Step 2: Render it** as the first line inside `<body>` in the layout:
  `<%= site_pattern_tag %>`. Delete line 2 of `pages/home.html.erb`.
- [ ] **Step 3: Move the CSS.** Delete `.home-pattern` (and its comment) from `pages/_home.scss`;
  add to `components/_layout.scss`:

```scss
// The seigaiha waves (seigaiha_controller.js, ApplicationHelper#site_pattern_tag) sit fixed
// behind every page, fading out under the navbar.
.site-pattern {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
  mask-image: linear-gradient(to bottom, transparent 0%, black 14%, black 100%);
  -webkit-mask-image: linear-gradient(to bottom, transparent 0%, black 14%, black 100%);
}

.main-content {
  position: relative;
  z-index: 1;
}
```

  (Merge the `.main-content` lines into the existing rule at the top of `_layout.scss`.)
- [ ] **Step 4: Boot check** — `~/.rbenv/shims/ruby bin/rails runner scripts/check-boot.rb`. Expected: passes.
- [ ] **Step 5: Find what hides the waves.** Start the server; in Chrome open `/projects`, `/photos`,
  `/blog_posts`, `/events`, one project page and one post page. On each, run this in the console
  (javascript tool) and list the hits:

```js
[...document.querySelectorAll("main *, main")].filter(el => {
  const c = getComputedStyle(el).backgroundColor
  const r = el.getBoundingClientRect()
  return r.width > window.innerWidth * 0.6 && r.height > 200 && c !== "rgba(0, 0, 0, 0)" && !c.endsWith(", 0)")
}).map(el => `${el.tagName}.${[...el.classList].join(".")} ${getComputedStyle(el).backgroundColor}`)
```

  For each page-wide box, set `background: transparent` in its stylesheet. For a box that holds
  body text (blog post body, event description), use `background: rgba(255, 253, 249, 0.85)`
  instead (the cream of `.slide-card`) so text stays readable.
- [ ] **Step 6: Walk it.** Home → strong waves; each inner page → faint waves that part near the
  cursor; `/photos/:id` and `/admin` → none. Turbo round trip Home → Projects → back → Photos:
  `document.querySelectorAll("canvas.site-pattern").length === 1` each time, and on Projects
  `document.querySelector(".site-pattern").dataset.seigaihaAlphaValue === "0.04"`. No console errors.
- [ ] **Step 7: Gates + commit.** Rubocop on `application_helper.rb`; boot check.
  `git add` the files above by name; `git commit -m "feat: seigaiha waves on every page, quieter inside"`.

---

### Task 2: Projects page — Menyu hero, eras, dates

**Files:**
- Create: `db/migrate/20260926090000_add_started_on_to_projects.rb`
- Modify: `app/models/project.rb` (scope `by_start`, constant `HERO_TITLE`)
- Modify: `lib/tasks/showcase.rake` (fill `started_on`)
- Modify: `app/controllers/projects_controller.rb#index`
- Modify: `app/controllers/admin/projects_controller.rb:70` and `app/views/admin/projects/_form.html.erb`
- Modify: `app/views/projects/index.html.erb`, `app/views/projects/_featured_project.html.erb`
- Modify: `app/views/pages/_project_slide.html.erb` (optional date; truncate on a word)
- Delete: `app/views/projects/_grid.html.erb` (its only caller is the index)
- Modify: `app/assets/stylesheets/components/_projects.scss`, `components/_showcase.scss`

**Interfaces:**
- Produces: `projects.started_on` (date, nullable); `Project.by_start` (newest `started_on` first,
  nulls last, then `created_at` desc); `@hero` (Project or nil) and `@eras` (ordered Hash
  section → [Project]) from `ProjectsController#index`; `pages/_project_slide` accepts `dated: true`.

- [ ] **Step 1: The migration** (Claude writes, Julian runs):

```ruby
class AddStartedOnToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :started_on, :date
  end
end
```

  **Stop here** and ask Julian to run `~/.rbenv/shims/ruby bin/rails db:migrate` locally.
  Confirm `db/schema.rb` gained `t.date "started_on"`.
- [ ] **Step 2: The model.** In `Project`:

```ruby
  HERO_TITLE = "Menyu".freeze # leads the Projects page

  scope :by_start, -> { order(arel_table[:started_on].desc.nulls_last, created_at: :desc) }
```

- [ ] **Step 3: The dates in `showcase.rake`.** Add `started_on:` to each featured hash and pass
  it through `assign_attributes` (`attrs.slice(:frame, :tags, :description, :started_on)`):
  Menyu `Date.new(2026, 6, 15)`, Sollo `Date.new(2026, 6, 5)`, MyTap `Date.new(2026, 9, 14)`,
  AlturaFlow `Date.new(2025, 6, 1)`, imagebank-reader `Date.new(2026, 9, 13)`,
  CS12 Skincare `Date.new(2026, 8, 1)`, YS Club `Date.new(2026, 9, 17)`.
  Replace the older-projects block with:

```ruby
    # Everything else stays on the Projects page, grouped by era, but off the home page.
    older = {
      "Tokyo Turntable" => ["bootcamp", Date.new(2025, 5, 26)],
      "レンtool" => ["bootcamp", Date.new(2025, 5, 1)],
      "Rails-watch-list" => ["bootcamp", Date.new(2025, 5, 1)],
      "Resume Auto-Fill Chrome Extension" => ["earlier", Date.new(2025, 6, 23)],
      "Portfolio website" => ["earlier", Date.new(2025, 6, 17)]
    }
    older.each do |title, (section, started_on)|
      project = Project.where("TRIM(title) = ?", title).first
      next puts("#{title}: not found, skipped") unless project

      project.update!(section: section, started_on: started_on, featured: false)
      puts "#{title}: #{section}, #{started_on.strftime('%b %Y')}"
    end
```

  Run `~/.rbenv/shims/ruby bin/rails showcase:load` (writes project rows only; allowed, it is the
  documented loader). Expected: 12 lines, none "not found".
- [ ] **Step 4: The controller:**

```ruby
  def index
    # Eager-load every image a card can show so each card doesn't query its own (N+1).
    @projects = Project.by_start
                       .with_attached_featured_image.with_attached_screenshots.with_attached_icon.to_a
    @hero = @projects.find { |p| p.title.to_s.strip.casecmp?(Project::HERO_TITLE) } || @projects.first
    @eras = Project::SECTIONS.index_with { |section| @projects.select { |p| p.section == section && p != @hero } }
                             .reject { |_, projects| projects.empty? }
  end
```

- [ ] **Step 5: Runner check** (write to the scratchpad as `check_projects.rb`, run with `bin/rails runner`):

```ruby
c = ProjectsController.new
c.index
hero = c.instance_variable_get(:@hero)
eras = c.instance_variable_get(:@eras)
raise "hero is #{hero&.title}" unless hero&.title&.strip == "Menyu"
raise "eras #{eras.keys}" unless eras.keys == %w[work earlier bootcamp]
eras.each do |section, list|
  dates = list.map(&:started_on)
  raise "#{section} not newest first: #{dates}" unless dates.compact == dates.compact.sort.reverse
end
raise "hero repeated" if eras.values.flatten.include?(hero)
raise "nil date not last" unless Project.by_start.to_sql.include?("NULLS LAST")
puts "ok: #{eras.transform_values { |l| l.map { |p| p.title.strip } }}"
```

  Expected: `ok: {"work"=>["YS Club", "MyTap", "imagebank-reader", "CS12 Skincare", "Sollo", "AlturaFlow"], ...}`
  (minus any project Julian holds back in Task 0).
- [ ] **Step 6: The card.** In `pages/_project_slide.html.erb`, change the truncate to cut on a
  word — `truncate(project.description.to_s.squish, length: 170, separator: " ")` — and make the
  footer dated when asked:

```erb
  <footer class="slide-card-footer<%= ' slide-card-footer--dated' if local_assigns[:dated] %>">
    <% if local_assigns[:dated] && project.started_on %>
      <time class="slide-card-date" datetime="<%= project.started_on.strftime('%Y-%m') %>">
        <%= project.started_on.strftime("%b %Y") %>
      </time>
    <% end %>
```

  Add to `_showcase.scss` after `.slide-card-footer`:

```scss
.slide-card-footer--dated {
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
}

.slide-card-date {
  margin-right: auto;
  font-size: 0.8rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  color: rgba(141, 11, 65, 0.7);
}
```

- [ ] **Step 7: The hero.** Rewrite `projects/_featured_project.html.erb` so the media side is the
  device card and the text side keeps title, description, tags, actions:

```erb
<%# The Projects page's lead: the app card at hero size beside its title, copy and links. %>
<section class="project-featured" itemscope itemtype="https://schema.org/CreativeWork">
  <%= link_to project_path(project),
      class: "project-featured-media slide-card-media slide-card-media--device slide-card-media--#{project.frame}",
      style: "--accent: #{project_accent(project)}", aria: { label: "View #{project.title.strip}" } do %>
    <% if project.frame == "phone" %>
      <%= render "projects/feature_phone", project: project %>
    <% else %>
      <%= render "projects/frame_#{project.frame}", project: project %>
    <% end %>
  <% end %>
  <div class="project-featured-body">
    <span class="project-featured-eyebrow">
      Featured project<% if project.started_on %> · <%= project.started_on.strftime("%b %Y") %><% end %>
    </span>
    <h2 class="project-featured-title" itemprop="name">
      <%= link_to project.title.strip, project_path(project), class: "text-decoration-none" %>
    </h2>
    <p class="project-featured-desc" itemprop="description"><%= project.description.to_s.squish %></p>
    <% if project.tag_list.any? %>
      <ul class="project-tags list-unstyled">
        <% project.tag_list.first(6).each do |tag| %>
          <li class="tag-pill" itemprop="keywords"><%= tag %></li>
        <% end %>
      </ul>
    <% end %>
    <div class="project-featured-actions d-flex flex-wrap gap-2">
      <% if project.live_url.present? %>
        <%= link_to project_live_url(project), class: "btn btn-primary", target: "_blank", rel: "noopener" do %>
          <% if project.live_url.include?("apps.apple.com") %>
            <i class="fab fa-app-store-ios me-1" aria-hidden="true"></i>App Store
          <% else %>
            <i class="fas fa-arrow-up-right-from-square me-1" aria-hidden="true"></i>Live site
          <% end %>
        <% end %>
      <% end %>
      <%= link_to project_path(project), class: "btn btn-outline-primary" do %>
        More about it <i class="fas fa-arrow-right ms-1" aria-hidden="true"></i>
      <% end %>
    </div>
  </div>
</section>
```

  In `_projects.scss`, give the hero media a size: `.project-featured-media { border-radius: 16px; aspect-ratio: 4 / 3; }`.
- [ ] **Step 8: The index.** In `projects/index.html.erb`, replace lines 64–71 (`if @projects.any?`,
  the hero pick and the grid) with the block below. The contact band and the `else` empty state
  after it stay unchanged, so zero projects still show "Projects Coming Soon" (Review Focus 3).

```erb
  <% if @hero %>
    <%= render "projects/featured_project", project: @hero %>
    <% @eras.each do |section, projects| %>
      <section class="project-era" aria-labelledby="era-<%= section %>">
        <h2 class="projects-grid-heading" id="era-<%= section %>"><%= section.titleize %></h2>
        <div class="project-era-grid">
          <%= render partial: "pages/project_slide", collection: projects, as: :project, locals: { dated: true } %>
        </div>
      </section>
    <% end %>
```

  The breadcrumb stays; the H1 gets `class="mb-3 page-title"`. Delete `projects/_grid.html.erb`.
  Add to `_projects.scss`:

```scss
.project-era-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.page-title { color: var(--burgundy); }
```

- [ ] **Step 9: Admin date field.** Permit `:started_on` in `Admin::ProjectsController#project_params`;
  in `admin/projects/_form.html.erb` after the featured checkbox:
  `<%= f.input :started_on, as: :date, html5: true, label: "Started (only the month is shown)" %>`.
- [ ] **Step 10: Walk it.** `/projects`: Menyu hero with its phone card; Work, Earlier, Bootcamp
  in that order, newest first, each card dated; hover shows whole-word descriptions; no "+N" pill;
  H1 burgundy. `/admin/projects/:id/edit` shows the date field. Home's sliders unchanged (no dates).
  No console errors. Check the phone-width CSS by reading it (`docs/dev.md` § Walking a route).
- [ ] **Step 11: Gates + commit.** Rubocop on the touched `.rb` files; boot check.
  Commit by name: `feat(projects): Menyu hero, eras sorted by start date`.

---

### Task 3: Photos — a contact sheet per place

**Files:**
- Modify: `app/models/photo.rb` (scope `in_roll_order`)
- Modify: `app/controllers/photos_controller.rb` (both actions use it)
- Modify: `app/views/photos/index.html.erb` (lines 20–38 become the sheet + the roll)
- Create: `app/assets/stylesheets/components/_contact_sheet.scss`; import it in `components/_index.scss`
- Delete: `app/assets/stylesheets/components/_photo_grid.scss` if nothing else uses `.photo-grid*`
  (grep first), and its import

**Interfaces:**
- Produces: `Photo.in_roll_order` (oldest upload first, then id). Anchors `#photo-<id>` on each
  full photo (the photo page's close link already targets them) and `#contact-sheet` on the sheet.

- [ ] **Step 1: The scope** in `Photo`: `scope :in_roll_order, -> { order(:created_at, :id) }`.
- [ ] **Step 2: The controller.** In `index`, replace `.recent` with `.in_roll_order`. In `show`,
  `@category_photos = Photo.by_category(@photo.category).in_roll_order` so the photo page's
  next/previous follow the same order as the sheet.
- [ ] **Step 3: Runner check** (`check_photos.rb`):

```ruby
hk = Photo.by_category("Hong Kong").in_roll_order.to_a
raise "count #{hk.size}" unless hk.size == 116
raise "not oldest first" unless hk.map(&:created_at) == hk.map(&:created_at).sort
missing = hk.count { |p| p.image.blob.metadata.values_at("width", "height").any?(&:nil?) }
raise "#{missing} without size" unless missing.zero?
puts "ok"
```

- [ ] **Step 4: The view.** Replace the `photo-grid` block (index lines 21–38) with:

```erb
    <section class="contact-sheet" id="contact-sheet" aria-label="Contact sheet: <%= @selected_category %>">
      <p class="contact-sheet-edge" aria-hidden="true">
        <span><%= @selected_category.upcase %></span><span><%= @photos.size %> frames</span>
      </p>
      <ol class="contact-sheet-frames">
        <% @photos.each_with_index do |photo, index| %>
          <li class="contact-frame">
            <a href="#photo-<%= photo.id %>" aria-label="Frame <%= index + 1 %>">
              <%= cl_image_tag photo.image.key,
                  width: 240, height: 160, crop: :fill, quality: :auto, fetch_format: :auto,
                  alt: "", loading: "lazy", draggable: false, oncontextmenu: "return false;" %>
            </a>
            <span class="contact-frame-number" aria-hidden="true"><%= index + 1 %></span>
          </li>
        <% end %>
      </ol>
    </section>

    <ol class="photo-roll">
      <% @photos.each_with_index do |photo, index| %>
        <% meta = photo.image.blob.metadata %>
        <li class="photo-roll-item" id="photo-<%= photo.id %>">
          <%= link_to photo_path(photo), class: "photo-roll-link" do %>
            <%= cl_image_tag photo.image.key,
                width: 1600, crop: :limit, quality: :auto, fetch_format: :auto,
                html_width: meta["width"], html_height: meta["height"],
                class: "photo-roll-image", loading: "lazy",
                alt: "Photo #{index + 1} from #{photo.category}",
                draggable: false, oncontextmenu: "return false;", onselectstart: "return false;",
                ondragstart: "return false;" %>
          <% end %>
          <p class="photo-roll-caption">
            <span><%= index + 1 %> / <%= @photos.size %></span>
            <a href="#contact-sheet">Back to the contact sheet</a>
          </p>
        </li>
      <% end %>
    </ol>
```

  Keep the `if @photos.any?` / empty-state branches and the `photo.image.attached?` guard (wrap
  each `li` in it). **Check `html_width`:** after rendering, the `<img>` must carry
  `width="4256" height="2832"` (the original's), not `1600`. If Cloudinary's helper maps them
  differently, pass `style: "aspect-ratio: #{meta['width']} / #{meta['height']}"` instead.
- [ ] **Step 5: The styles** — `components/_contact_sheet.scss`:

```scss
// Photos index: a film contact sheet for the chosen place (black strips, sprocket holes, frame
// numbers), then the full photos. Frames link to #photo-<id> below.
$film: #141210;
$film-edge: #e8a33c; // the orange print on a film's edge

.contact-sheet {
  margin: 0 0 3rem;
  padding: 0.75rem;
  background: $film;
  border-radius: 4px;
  box-shadow: var(--shadow-lg);
}

.contact-sheet-edge {
  display: flex;
  justify-content: space-between;
  margin: 0 0 0.5rem;
  font: 600 0.75rem/1 ui-monospace, SFMono-Regular, Menlo, monospace;
  letter-spacing: 0.18em;
  color: $film-edge;
}

.contact-sheet-frames {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(112px, 1fr));
  row-gap: 0.6rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

// Each frame carries its own sprocket holes above and below, so a full row reads as one strip.
.contact-frame {
  position: relative;
  padding: 14px 3px 20px;
  background:
    repeating-linear-gradient(90deg, transparent 0 5px, #d9d2c3 5px 11px, transparent 11px 16px) top 4px left 0 / 100% 6px no-repeat,
    repeating-linear-gradient(90deg, transparent 0 5px, #d9d2c3 5px 11px, transparent 11px 16px) bottom 4px left 0 / 100% 6px no-repeat,
    $film;

  a { display: block; }

  img {
    display: block;
    width: 100%;
    aspect-ratio: 3 / 2;
    object-fit: cover;
    user-select: none;
    -webkit-user-drag: none;
    transition: filter 0.2s ease;
  }

  a:hover img,
  a:focus-visible img { filter: brightness(1.15); }

  a:focus-visible { outline: 2px solid $film-edge; outline-offset: 2px; }
}

.contact-frame-number {
  position: absolute;
  left: 6px;
  bottom: 9px;
  font: 600 0.6rem/1 ui-monospace, SFMono-Regular, Menlo, monospace;
  color: $film-edge;
}

.photo-roll {
  display: grid;
  gap: 3rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.photo-roll-item {
  scroll-margin-top: 90px; // clears the fixed navbar when a frame jumps here
  text-align: center;
}

.photo-roll-image {
  max-width: 100%;
  height: auto;
  max-height: 85vh;
  width: auto;
  border: 6px solid #fff;
  box-shadow: var(--shadow-lg);
  user-select: none;
  -webkit-user-drag: none;
}

.photo-roll-caption {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 0.6rem;
  font-size: 0.85rem;
  color: #6b6b6b;
}

@media (prefers-reduced-motion: no-preference) {
  html:has(.contact-sheet) { scroll-behavior: smooth; }
}

@media (max-width: 575px) {
  .contact-sheet-frames { grid-template-columns: repeat(auto-fill, minmax(84px, 1fr)); }
  .photo-roll-image { border-width: 3px; }
}
```

  Import it in `components/_index.scss` next to the other photo files.
- [ ] **Step 6: Walk it.** `/photos` → first place's sheet, then its photos. Click frame 90 on
  Hong Kong before scrolling: lands on photo 90, under the navbar, and stays (Review Focus 1).
  "Back to the contact sheet" returns up. Tap a full photo → photo page; its X returns to that
  photo on the index. Photo page arrows go frame 5 → 6 (same order). Right-click on a frame does
  nothing. Turbo round trip: no console errors. Network tab: full photos below the fold aren't
  fetched until scrolled near.
- [ ] **Step 7: Gates + commit.** Rubocop on `photo.rb`, `photos_controller.rb`; boot check.
  Commit by name: `feat(photos): contact sheet per place with the full roll below`.

---

### Task 4: Home photo viewer matches the photo page

**Files:**
- Modify: `app/views/photos/_photo_modal.html.erb`
- Modify: `app/javascript/controllers/photo_modal_controller.js`
- Modify: `app/assets/stylesheets/components/_photo_modal.scss`

**Interfaces:**
- Consumes: the slide links' `data-photo-url` / `data-photo-alt` (`pages/_photo_slide.html.erb`);
  `.photo-frame` (`_photo_frame.scss`), `.btn-close-photo` and `.btn-side-nav` (`_photo_buttons.scss`).

- [ ] **Step 1: Find the cause first** (superpowers:systematic-debugging). On Home, click a
  photo and run:

```js
const m = document.querySelector("#photoModal")
const probe = el => el && { cls: el.className, bg: getComputedStyle(el).backgroundColor, op: getComputedStyle(el).opacity, z: getComputedStyle(el).zIndex }
;[m, m.querySelector(".modal-dialog"), m.querySelector(".modal-content"), document.querySelector(".modal-backdrop")].map(probe)
```

  Then, in DevTools-equivalent terms, find which rule wins on `.modal-content` (search the SCSS for
  `.modal-content` and `.modal-fullscreen` and `#photoModal`: `grep -rn` under
  `app/assets/stylesheets`). Write the cause into `claude-talk.md` in one line before fixing.
  Fix the cause, not with a new `!important`.
- [ ] **Step 2: The markup** — `photos/_photo_modal.html.erb`:

```erb
<%# Full-screen photo viewer for Home, styled like the photo page (photos/show): black page,
    white-framed photo, a quiet X, and arrows through the featured photos
    (photo_modal_controller.js). Open it with a link carrying data-bs-toggle="modal",
    data-bs-target="#photoModal" and data-photo-url. %>
<div class="modal fade" id="photoModal" tabindex="-1" aria-label="Photo viewer" aria-hidden="true"
     data-controller="photo-modal" data-action="keydown->photo-modal#key">
  <div class="modal-dialog modal-fullscreen">
    <div class="modal-content">
      <button type="button" class="btn btn-close-photo photo-modal-close" data-bs-dismiss="modal" aria-label="Close">
        <i class="fas fa-times" aria-hidden="true"></i>
      </button>
      <div class="modal-body">
        <button type="button" class="btn btn-side-nav photo-modal-prev" data-photo-modal-target="prev"
                data-action="photo-modal#prev" aria-label="Previous photo">
          <i class="fas fa-chevron-left" aria-hidden="true"></i>
        </button>
        <div class="photo-frame">
          <img src="" alt="" class="photo-main-image" data-photo-modal-target="image" draggable="false">
        </div>
        <button type="button" class="btn btn-side-nav photo-modal-next" data-photo-modal-target="next"
                data-action="photo-modal#next" aria-label="Next photo">
          <i class="fas fa-chevron-right" aria-hidden="true"></i>
        </button>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 3: The controller** — `photo_modal_controller.js`:

```js
import { Controller } from "@hotwired/stimulus"

// Full-screen photo viewer for Home. The link that opens the Bootstrap modal carries the image URL
// in data-photo-url; the arrows (and arrow keys) step through every such link on the page.
export default class extends Controller {
  static targets = ["image", "prev", "next"]

  connect() {
    this.onShow = (event) => {
      this.triggers = [...document.querySelectorAll('[data-bs-target="#photoModal"][data-photo-url]')]
      this.show(this.triggers.indexOf(event.relatedTarget))
    }
    this.element.addEventListener("show.bs.modal", this.onShow)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.onShow)
  }

  prev() { this.show(this.index - 1) }
  next() { this.show(this.index + 1) }

  key(event) {
    if (event.key === "ArrowLeft") this.prev()
    if (event.key === "ArrowRight") this.next()
  }

  show(index) {
    const trigger = this.triggers?.[index]
    if (!trigger) return
    this.index = index
    this.imageTarget.src = trigger.dataset.photoUrl
    this.imageTarget.alt = trigger.dataset.photoAlt || "Photo"
    this.prevTarget.hidden = index === 0
    this.nextTarget.hidden = index === this.triggers.length - 1
  }
}
```

  Bootstrap already returns focus to the link that opened the modal when it closes; confirm it.
- [ ] **Step 4: The styles.** Replace `_photo_modal.scss` with only what the shared classes don't
  give: the black page, the layout, and the button positions.

```scss
// Home's photo viewer (photos/_photo_modal.html.erb). The frame and buttons come from the photo
// page's styles (_photo_frame.scss, _photo_buttons.scss); this file only lays them out.
#photoModal {
  .modal-content {
    background: #000;
    border: 0;
    border-radius: 0;
  }

  .modal-body {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    padding: 1rem;
  }

  .photo-frame { margin: 0; }

  .photo-main-image {
    max-width: calc(100vw - 160px);
    max-height: calc(100vh - 100px);
    pointer-events: none;
  }

  .photo-modal-close {
    position: fixed;
    top: 20px;
    left: 20px;
    z-index: 1060;
  }

  [hidden] { visibility: hidden; display: flex !important; } // keep the photo centred when an arrow hides
}

@media (max-width: 768px) {
  #photoModal {
    .btn-side-nav { display: none; }
    .photo-main-image { max-width: calc(100vw - 24px); }
  }
}
```

  If Step 1's cause was a rule outside this file, its fix lands there instead; don't duplicate it here.
- [ ] **Step 5: Walk it.** Home → click a featured photo: black page, white frame, quiet white X
  top-left, same as `/photos/:id` side by side. Arrows and ← → step through the five featured
  photos; at photo 1 the left arrow is hidden and ← does nothing; at photo 5 likewise on the right
  (Review Focus 5). Escape and X close; focus is back on the clicked photo. Turbo round trip
  Home → Photos → Home, open again: works, no console errors.
- [ ] **Step 6: Gates + commit.** Boot check. Commit by name:
  `fix(home): photo viewer matches the photo page`.

---

### Task 5: Docs, one checker, push

- [ ] **Step 1: Docs in place.** `docs/frontend.md` (the layout owns the waves canvas and
  `site_pattern_tag`; the photo modal's arrows), `docs/styling.md` (`_contact_sheet.scss`, the
  pattern moved to `_layout.scss`), `docs/architecture.md` (`projects.started_on`,
  `Project.by_start`, `Photo.in_roll_order`), `docs/status.md` (delete the Projects-page and
  photos lines this closed; add "migrate + showcase:load on Heroku at Julian's go").
- [ ] **Step 2: Doc guards** — `scripts/check-doc-size.sh`, `scripts/check-doc-staleness.sh`.
- [ ] **Step 3: One independent checker** (`workers/checker.md`) on Tasks 1–4. Fix what it finds.
- [ ] **Step 4:** Commit docs by name (`docs: pages redesign`), push to `origin`. Drain
  `claude-talk.md`. Heroku (`git push heroku master`, `heroku run rails db:migrate`,
  `heroku run rails showcase:load`) only at Julian's go.
