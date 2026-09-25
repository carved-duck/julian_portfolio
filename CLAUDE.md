# Julian Schoenfeld portfolio — map for Claude (Layer 0)

Julian's personal site: a web developer and photographer in Tokyo. Projects, a blog, a photo
gallery, and casual events with signups. The voice is his: first person, warm, not corporate.
Rails 7.1 + Hotwire, live on Heroku.

**This file stays small on purpose.** It holds only what every session needs and where to look.
It does not grow unless Julian says so: a hook blocks Claude, and `scripts/check-doc-size.sh` fails
the commit. New facts go in a `docs/` file; a new file's pointer goes in [`CONTEXT.md`](CONTEXT.md).

## Start here
1. Read `claude-talk.md` (in-flight notes, wiped on push) and `docs/status.md` (what's open).
2. Wait for Julian's direction. Work on `master`; the steps are `workers/workflow.md`.

## Canonical facts
- **Identity:** "Julian Schoenfeld" or "Julian". Contact `julian@trendrider.io` · Instagram `@jju.irl`.
  The old `trendrider.io` domain in the repo name and email is fine; don't "fix" it unasked.
- **Deploy:** Heroku (`heroku` remote, buildpacks). GitHub is `origin`.
- **Admin:** `/admin` behind HTTP Basic Auth only. No sessions, no roles.

## Rules that never bend
- Anything that must run on every page visit listens for `turbo:load`, and Stimulus `disconnect()`
  undoes `connect()`: `docs/frontend.md`.
- Never run destructive database tasks (`db:migrate`, `db:drop`, `db:reset`, `db:schema:load`).
  Julian runs DB tooling. Localhost uses its own copy of the data: `docs/dev.md`.
- Commits and pushes to `origin` are authorized (standing OK, 2026-05-24): Conventional Commits,
  once at the end of a task. Deploying to Heroku only at Julian's go.
- Never add a `Co-Authored-By` or any Claude/AI trailer. Never bypass hooks (`--no-verify`).
- One independent checker ends every session that changed files: `workers/checker.md`.
- Verify before claiming done: run it, read it, open the route.

## Where to look
| Topic | File |
|---|---|
| What's open now | `docs/status.md` |
| Stack, data model, auth, images, email, env vars | `docs/architecture.md` |
| Turbo, Stimulus, the slider | `docs/frontend.md` |
| SCSS layout, brand colors | `docs/styling.md` |
| Running the app, gates, local traps | `docs/dev.md` |
| SEO · contact-form spam defenses | `docs/seo.md` · `docs/spam-protection.md` |
| How a task runs · the hats | `workers/workflow.md` · `workers/` |
| Anything else | `CONTEXT.md` |

## The doc layers (ICM)
| Layer | Holds | Where |
|---|---|---|
| 0 · map | always-true facts + where to look | this file (frozen size) |
| 1 · router | which file for which task | `CONTEXT.md` |
| 2 · process | how a task runs | `workers/workflow.md` |
| 3 · reference | facts by topic; hat checklists | `docs/*.md` · `workers/*.md` |
| 4 · this task | notes, open items | `claude-talk.md` · `docs/status.md` · commit messages |
