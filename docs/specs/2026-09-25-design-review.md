# Design review — Julian Schoenfeld portfolio

Reviewed live at `http://localhost:3000` (desktop, 1440×900) plus a read of the views/SCSS/JS
listed in the brief. Wearing the uiux hat (`workers/uiux.md`): the work is the hero, my job is
to get out of its way.

---

## 1. The home page background

### What's there now, and why it doesn't fit

`dot_grid_controller.js` draws a `<canvas>` grid of burgundy dots (`rgb(141,11,65)`, 18px
spacing, 1.2px radius, 0.2 alpha) that flee the mouse and ripple on tap. Looking at
`/projects/102` confirms where this came from: it's a direct descendant of **AlturaFlow**,
a trading-chart product Julian worked on, whose own hero literally reads *"Every dot is a stock. Yours
are highlighted."* On a stock-market SaaS, a field of dots that react to you like a live
market is exactly right. On a photographer's personal site, the same animation is a field of
**nothing** reacting to you for no reason — precise, cold, quantitative. It reads as
"analytics dashboard," which is the one thing this site explicitly isn't (`workers/uiux.md`:
*"Think gallery, not dashboard"*). Julian's instinct that it "doesn't make sense" is correct.

The fix isn't to drop texture — a flat cream field would be a step backward — it's to change
what the texture *means*. The best options tie to the thing Julian actually makes: photographs.

### Top pick: film grain

A fine, warm-toned analog noise layer across the cream page — the actual physical texture of
the medium Julian shoots in. It's the opposite of "AI-generated": grain is a distinctly
*human, imperfect* texture, not a smooth gradient or a perfect procedural pattern, so it
avoids the generic-SaaS-hero look this review was asked to watch for.

- **Technique:** one fixed `<div>`, background-image = inline SVG `feTurbulence`
  (`type="fractalNoise"`, `baseFrequency 0.9`, `numOctaves 2`), tinted warm dark brown via
  `feColorMatrix` rather than true black/white so it reads as a print, not TV static.
- **Opacity:** 5% (`0.05`). At the current dot grid's 0.2 alpha-per-dot the page reads as
  "pattern"; grain has to sit well under that or it looks like a bad camera sensor, not paper.
- **Blend mode:** `multiply` over `#fefcf8`, so it only ever darkens, never washes out white
  card backgrounds sitting on top.
- **Colour:** not burgundy — a warm near-black (`rgba(56,40,46,·)` used in the color matrix),
  so it doesn't fight the burgundy headline for the eye's attention.
- **Scale:** tiled 180×180px SVG, repeating — cheap, resolution-independent, no banding.
- **Animated?** No, by default. Grain is a texture, not an effect; a static layer is
  indistinguishable from a flickering one at 5% opacity and costs zero CPU. I've included an
  optional slow (26s), barely-visible warm-light drift underneath as a nice-to-have, gated
  behind `prefers-reduced-motion`, but it's cuttable with no loss.
- **Interactivity:** none. This is a deliberate choice, not an oversight — grain doesn't
  semantically respond to a cursor, and dropping the "flee from mouse" gimmick entirely is
  part of what fixes the AlturaFlow-shaped hole. If Julian misses having *something* respond
  to the mouse, Option B is the one to reach for.
- **Behind photos/device mockups:** invisible — it sits at `z-index: 0` under a `multiply`
  blend, and opaque cards (`#fffdf9`, phone/browser frames) fully occlude it. No contrast risk
  for text or images.
- **Performance:** effectively free — one static image paint, no canvas, no per-frame JS, no
  `requestAnimationFrame` loop running for the life of the page (a real cost the current
  implementation pays even at rest).
- **Risk of looking gimmicky/AI-made:** low. This is the safest, most "obviously intentional"
  option of the three.

### Runner-up: contact sheet / light table

A loose grid of empty 3:2 frame outlines with tiny sprocket-hole ticks — literally blank slots
on a contact sheet, waiting to be filled with the work below. It keeps the current grid's
*structure* (so it's a smaller leap for Julian, who likes the current layout) while swapping
the *meaning* from "market data" to "your film."

- **Colour/opacity:** burgundy hairline stroke, `rgba(141,11,65,0.09)` base, 1px line.
- **Scale:** 108×72px frames on a 154×118px cell (frame + 46px gutter) — sparse enough to read
  as texture, not a spreadsheet.
- **Interactivity, kept but re-themed:** the frame nearest the cursor brightens toward
  `rgba(141,11,65,0.37)`, like a loupe passing over a light table. Same "the page notices you"
  feeling as today, no repulsion physics, no ripple-on-tap borrowed from a chart.
- **Behind cards:** frames are hairline and low-alpha, so they disappear under any opaque
  card; no legibility risk.
- **Performance:** one small canvas redraw on `pointermove`/`resize`, no per-frame RAF loop —
  cheaper than the current implementation, which animates continuously even when the mouse
  never moves.
- **Risk:** slightly more "designed object" than film grain — a good sell if Julian wants to
  keep a visible interactive moment; skip if he'd rather the background disappear entirely.

### Also considered, and why they're a step down

| Option | Verdict |
|---|---|
| **Seigaiha / asanoha (Japanese pattern)**, prototyped as `bg-c.html` | Legitimate third choice if Julian wants to foreground **Tokyo** over **photography** specifically — it's his adopted city, not his craft. Kept at ~5% opacity it's tasteful; push it any bolder or more colourful and it slides into "izakaya menu" cliché. Third pick, not because it's bad, but because it says less about *him*. |
| **Bokeh / light leaks** | **Avoid.** Soft blurred colour blobs are the single most common "photography portfolio" background on template marketplaces and AI page generators right now — this is the one most likely to make the site look templated rather than personal, which is the opposite of the brief. |
| **Topographic contour lines** | **Avoid.** Reads as "outdoor gear app" or "hiking tracker," not photography or Tokyo specifically — no real tie to Julian. |
| **Risograph / halftone dots** | **Avoid.** Loud, trendy, and it fights the warm editorial voice (`workers/uiux.md`: "editorial layout... type that gets out of the way"); also visually close enough to the current dot grid that it wouldn't read as a fix. |
| **Hand-drawn ink texture** | **Avoid.** Mismatched with the clean, structured half of the brand (the dev work, the phone/browser mockups); would make the two "doors" feel like two different sites. |
| **Keeping the current mouse-repel physics, recoloured** | **Avoid.** The problem was never the colour, it was the concept — dots fleeing a cursor is a specific, borrowed metaphor from a trading UI. Recolouring it doesn't remove where it's from. |

**Bottom line:** ship film grain (`bg-a.html`) as the default. If Julian wants to keep a
mouse-reactive moment, ship the contact-sheet grid (`bg-b.html`) instead — both are large
upgrades over the current dot field. Don't ship bokeh, contour lines, halftone, or ink.

---

## 2. Full-site check

### Critical (breaks the flow / looks unfinished)

1. **Blog empty state is a dead end.** `/blog` with 0 posts shows a plain box top-left —
   *"No blog posts yet. Blog posts will appear here once they're published."* — floating in a
   huge empty page, no link anywhere else to go. Compare to the home page's own empty states
   (`showcase-empty` in `_showcase.scss`), which correctly *sell the next action*: "I'm picking
   my favourite shots. For now, browse all photos." **Fix:** give Blog's empty state the same
   pattern — acknowledge it, then point at Photos or Projects — and restyle the box to match
   the site's card language (rounded 16px, `--shadow-sm`) instead of a flat Bootstrap alert.

2. **Two visual eras on one site.** The home page was just redesigned (rounded 16px
   `.slide-card`s, warm shadows, hover-lift, burgundy accents) but Projects/Events/Blog still
   use an older, flatter card style (grey `#f4f4f4`-ish body, square-ish corners, plain
   headings) — visible the instant you click "See all projects" from the new home page into
   the old-style grid. This is the single biggest inconsistency on the site and the most
   valuable fix available. **Fix:** roll the `.slide-card` component (and its hover-reveal
   text pattern, see #3) out to the Projects, Events, and Blog listings so clicking through
   from home doesn't feel like landing on a different site.

3. **Mid-word truncation reads as broken.** Project card descriptions on `/projects` cut off
   with `…` mid-sentence: *"I think this has bee…"*, *"…flip back to show your…"*. This is the
   exact trap `workers/uiux.md` calls out: *"Truncation as a substitute for layout."* The home
   page's own new slide-cards already solve this correctly — full text is hidden and revealed
   on hover/focus instead of hard-clamped. **Fix:** reuse that hover-reveal pattern on the
   Projects listing rather than a fixed-line clamp (a copy-length fix alone won't hold once a
   longer project description is added).

### Warnings (rough edges)

4. **Bare `+16` / `+8` tag pills.** On Projects cards, extra tags collapse to an unlabeled
   number ("Ruby on Rails, JavaScript, HTML5, CSS3, **+16**"). `workers/uiux.md` rule 5: *"Bare
   numbers and bare icons need context."* **Fix:** at minimum `aria-label="16 more
   technologies"`; better, make it click/tap-to-expand.

5. **Single-item pages look lopsided.** `/events` (one event) and `/blog` (zero posts) both
   render a card pinned to the top-left of a grid built for many, leaving a large dead area to
   the right at desktop width. **Fix:** cap and center a lone card instead of leaving it in a
   multi-column grid track.

6. **Heading colour splits between pages.** Home's H1 ("Hey, I'm Julian") is burgundy, the
   brand primary; every inner page's H1 ("Web Development Projects," "Photo Gallery," "Blog,"
   "Events") is near-black. Both are legitimate editorial choices, but having both at once on
   the same brand reads as unplanned rather than deliberate. **Fix:** pick one rule for H1
   colour and apply it everywhere.

### Polish

7. **Photo grid and its filter pills are already fully on-brand** (burgundy active pill,
   clean masonry grid) — worth knowing the redesign gap is really concentrated in *cards*
   (Projects/Events/Blog), not full pages, which narrows the fix in #2.
8. **The hero letter-wave-in re-plays on every visit**, including repeat/back navigation.
   Minor; not worth touching unless it starts to feel like a tax to returning visitors.
9. **What already works well and shouldn't be touched:** the card slider (`_slider.html.erb` +
   `slider_controller.js`) is a genuinely clean, accessible replacement for the old carousel —
   scroll-snap, real touch/keyboard scrolling, nothing to re-initialize on Turbo visits. The
   device-frame project cards (phone/browser/terminal mockups in brand colours) are a
   distinctive, non-generic way to preview work and are the best thing on the site right now.
   The shadow/spacing token system (`--shadow-sm/md/lg`, CSS colour variables) is used
   consistently wherever the new design has landed.

---

## Prototype files

- `bg-a.html` — **top pick**, film grain
- `bg-b.html` — **runner-up**, contact sheet / light table (mouse-reactive)
- `bg-c.html` — alternative, seigaiha waves (Tokyo-forward, not the recommendation)

Each is self-contained (inline CSS/SVG/JS, no external requests) and mocks the home page hero,
tagline, two door buttons, and a row of three placeholder cards so the background can be judged
behind real content.
