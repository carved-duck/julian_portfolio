# Portfolio — CONTEXT (Layer 1: which file for which task)

ELI5: name the task, and this table tells you which file to open.
**What leaves this repo:** a `git push heroku master` deploy, only at Julian's go.

## Task → file
| If the task is about… | Open |
|---|---|
| what's open, owed, next | `docs/status.md` |
| how a task runs end to end | `workers/workflow.md` |
| controllers, models, services, jobs, Stimulus JS | `workers/engineer.md` · `docs/architecture.md` · `docs/frontend.md` |
| views, layout, SCSS, responsive, the home page | `workers/uiux.md` · `docs/styling.md` · `docs/frontend.md` |
| copy, voice, page titles, meta descriptions | `workers/writer.md` · `docs/seo.md` |
| events, BBQ capacity, attendee signup | `docs/architecture.md` § Domain model |
| photos, uploads, Cloudinary, compression | `docs/architecture.md` § Images |
| the contact form, spam, email | `docs/spam-protection.md` · `docs/architecture.md` § Contact form and email |
| admin area, auth | `docs/architecture.md` § Auth boundary |
| SEO, structured data, sitemap | `docs/seo.md` |
| running locally, the local database, gates, the wrong-Ruby trap | `docs/dev.md` |
| reviewing a change (the one checker) | `workers/checker.md` |
| a big or risky change's design | `docs/specs/` (dated; history, not live facts) |

## Run · check · ship
- **Checks:** by risk, once at the end (`workers/workflow.md`); commands in `docs/dev.md`.
- **Run locally:** `~/.rbenv/shims/ruby bin/rails server`.
- **Ship:** commit + push to `origin` at the end of a task. Heroku deploy only at Julian's go.

## Do NOT
- Bypass the pre-commit hooks with `--no-verify`.
- Run destructive `db:*` tasks: Julian runs DB tooling.
