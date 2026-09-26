# Dev — running the app, the gates, local gotchas

ELI5: how to start the app and check a change, and the traps that bite first. Checked 2026-09-25.

## Trap 1: the wrong Ruby
`bin/rails` starts with `#!/usr/bin/env ruby`. In a shell without rbenv on the PATH (Claude's
shell, for one) that finds macOS's system Ruby 2.6 and fails with a Gemfile / bundler error.
Run it through the rbenv Ruby explicitly:

```bash
~/.rbenv/shims/ruby bin/rails <command>
~/.rbenv/shims/bundle exec rubocop <files>
```

## Trap 2: `DATABASE_URL` in `.env` beats `database.yml`
`dotenv-rails` loads `.env` in development and test, and a `DATABASE_URL` there overrides
`config/database.yml`. Keep it out of `.env`: production gets its own from Heroku.

## The local database
Since 2026-09-25 localhost runs on its own Postgres database, `julian_portfolio_development`: a copy
of production made with `heroku pg:pull` (its "6 errors ignored" warning was harmless; row counts
matched Heroku table for table). Editing records locally never touches the live site. To refresh it
from production (Julian runs DB tooling):

```bash
dropdb julian_portfolio_development
heroku pg:pull DATABASE_URL julian_portfolio_development -a julian-portfolio
```

The test database (`julian_portfolio_test`) has not been created; the suite is broken anyway (below).

## Commands
| What | Command |
|---|---|
| Run the app | `~/.rbenv/shims/ruby bin/rails server` → http://127.0.0.1:3000 (no `bin/dev`, no `Procfile.dev`) |
| First-time setup | `bin/setup` |
| Lint | `~/.rbenv/shims/bundle exec rubocop <changed files>` |
| Boot check | `~/.rbenv/shims/ruby bin/rails runner scripts/check-boot.rb` |
| Doc guards | `scripts/check-doc-size.sh` · `scripts/check-doc-staleness.sh` |
| Load the dev-work cards | `~/.rbenv/shims/ruby bin/rails showcase:load` — creates/updates them by title from `db/showcase/projects.yml` (copy, tags, order) and the images beside it (`FORCE_IMAGES=1` re-uploads), and sets the older projects' copy and tags too. Each run resets every listed project's copy to the file, overriding admin edits |
| Tests | `bin/rails test` (minitest, parallel; system tests in `test/system/`, Capybara + Chrome) — **broken today**, see Test suite state |

- **Lint baseline:** rubocop is not clean repo-wide (mostly `Metrics` and long-line noise). The bar is
  no *new* offenses on the lines you touched. The rule that bites is `Layout/LineLength` at 120.
  Don't rename `is_bot_request?` to please the `Naming/PredicatePrefix` cop (Julian, 2026-05-24).
- **Boot check** (`scripts/check-boot.rb`): the app eager-loads, `application.css` compiles *and*
  survives production's Sass compressor, and every ERB view compiles. No database, no browser. It
  does not prove a page renders right. The compressor re-reads the finished CSS, so CSS `min()` /
  `max()` / `clamp()` mixing units (`min(340px, 100%)`) fails there even when dev is fine; it
  rejected a Heroku build on 2026-09-25. Use a media query instead.
- **Test suite state:** the admin scaffold tests (`test/controllers/admin/*`, `test/system/admin/*`)
  call fixtures like `admin_projects(:one)` that don't exist, so they all error. Repair or remove is
  an open call in `status.md`.

## Walking a route
After the boot check, open each changed page at desktop width and at phone width (~375px). The
home page (doors, sliders) and the photo viewer are where phone bugs show up first.

Claude's Chrome tool cannot reach phone width: the viewport stayed at 1470px whatever
`resize_window` did (May 2026). So Claude walks desktop and checks mobile in the markup and CSS,
and the phone-width look is Julian's check in Chrome's device toolbar. Say which one was done.
