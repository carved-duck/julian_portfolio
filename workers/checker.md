# Checker — the review checklist

ELI5: the one fresh pair of eyes at the end of every session that changed files.
It runs as a new subagent with no memory of the work (`workflow.md` step 6). This is the floor,
not the ceiling: a clean checklist means the work is not obviously broken, not that it is good.

## Inputs / Outputs

**Inputs**
- Layer 0: `../CLAUDE.md` — always
- Layer 4: `../claude-talk.md` — every entry since the last push; that is the surface under review
- Layer 3: this checklist, plus the brief of whichever hat did the work, plus the `../docs/` file
  for each area the change touches
- Code of record: the diff (`git -C <repo> diff`), then its neighbours, then the ripple

**Outputs**
- findings sorted into errors / warnings / suggestions, each with file:line and a proposed fix
- the gate commands it ran, with their output; never a claim without it
- no edits: the checker reports, and the session that dispatched it applies the fixes (`workflow.md` step 6)

How deep to go (safety / normal / docs) is the risk table in `workflow.md`.

## Three passes
1. **Changed files only.** Security and correctness first. Run the gates.
2. **Changed files + neighbours.** Partials that render them, controllers that feed them,
   stylesheets that style them. Look for duplication, broken contracts, missed reuse.
3. **Ripple.** Search for everything else that reads the same model, partial, CSS class, or
   Stimulus controller, and check it still works.

## Security
- [ ] CSRF protection intact (no `skip_before_action :verify_authenticity_token` without a
      reason; the contact form's fetch sends the CSRF token).
- [ ] Strong params on every create and update. No raw `params` passed to a model.
- [ ] Admin actions live under `/admin` and inherit `Admin::BaseController`. Nothing admin-only
      on a public controller.
- [ ] No secrets, API keys, or `ENV` values in the page or in client JS.
- [ ] Contact-form changes keep every spam layer working (`../docs/spam-protection.md`).
- [ ] Security headers in `ApplicationController` still set (X-Frame-Options,
      X-Content-Type-Options, X-XSS-Protection).
- [ ] Photo-protection behavior on the gallery not silently broken.

## Code quality
- [ ] Logic lives in models and services; controllers stay thin.
- [ ] No N+1: `includes` / `with_attached_*` when a view iterates associations or images.
- [ ] No dead code, no single-caller helper hiding three readable lines, no rescue that only re-raises.
- [ ] Names make comments unnecessary.
- [ ] No new rubocop offenses on touched lines (`Layout/LineLength` 120 is the usual one).

## Hotwire and frontend (`../docs/frontend.md`)
- [ ] Anything that must run on every visit listens for `turbo:load`.
- [ ] Stimulus `disconnect()` removes what `connect()` added, using stored references (not a
      fresh `.bind(this)`).
- [ ] Carousel changes dispose the existing Bootstrap instance before creating a new one.
- [ ] New JS dependencies pinned in `config/importmap.rb`.
- [ ] Nothing goes stale after a Turbo navigation (`turbo:before-cache`, `data-turbo-permanent`).

## UX
- [ ] The zero-patience test: a first-time, distracted visitor knows what to do in five seconds.
- [ ] One primary action per view.
- [ ] Empty states do real work.
- [ ] Renders at 320px; tap targets at least 44x44px; carousel and photo swipe work by touch.
- [ ] Destructive admin actions confirm first and state the consequence plainly.
- [ ] Keyboard reachable: focusable, focus ring visible, Escape closes modals.

## Images
- [ ] Uploads go through Active Storage (Cloudinary outside test).
- [ ] Large images pass through `ImageCompressionService`; bulk uploads use `BulkPhotoUploadJob`.
- [ ] Images have meaningful `alt` text.

## SEO (`../docs/seo.md`)
- [ ] New public pages set a title and meta description via `SeoConfig` and the helpers.
- [ ] New content types appear in `/sitemap.xml` with the right structured data.
- [ ] Canonical URL, Open Graph and Twitter tags present.

## Tests
- [ ] The gates for this risk level ran and passed (`workflow.md`; commands in `../docs/dev.md`).
- [ ] A bug fix adds the test that would have caught it, once the suite is runnable again.

## Docs
- [ ] Any fact the change made false is fixed in place in its `docs/` file, stale copy deleted.
- [ ] `scripts/check-doc-size.sh` and `scripts/check-doc-staleness.sh` pass.
