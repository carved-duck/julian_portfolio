# Dev — running the app, the gates, local gotchas

ELI5: how to start the app and check a change, and the two traps that bite first. Checked 2026-09-25.

## Trap 1: the wrong Ruby
`bin/rails` starts with `#!/usr/bin/env ruby`. In a shell without rbenv on the PATH (Claude's
shell, for one) that finds macOS's system Ruby 2.6 and fails with a Gemfile / bundler error.
Run it through the rbenv Ruby explicitly:

```bash
~/.rbenv/shims/ruby bin/rails <command>
~/.rbenv/shims/bundle exec rubocop <files>
```

## Trap 2: the local app may be talking to production
The May 2026 recon found `.env` sets `DATABASE_URL` to the **Heroku production database**, and
`dotenv-rails` loads `.env` in development and test. `database.yml`'s local database names are still
the template placeholders (`change_this_to_your_rails_app_name_*`), so there is no local database.
Until that is fixed (open item in `status.md`):
- `rails server` reads and writes **live data**. Fine for looking; never create, edit or delete
  records from a local session without Julian's say-so.
- **Do not run `bin/rails test`** or any `db:*` task. The test setup could touch the production
  database, and the suite is broken anyway (below).

## Commands
| What | Command |
|---|---|
| Run the app | `~/.rbenv/shims/ruby bin/rails server` → http://127.0.0.1:3000 (no `bin/dev`, no `Procfile.dev`) |
| First-time setup | `bin/setup` |
| Lint | `~/.rbenv/shims/bundle exec rubocop <changed files>` |
| Boot check | `~/.rbenv/shims/ruby bin/rails runner scripts/check-boot.rb` |
| Doc guards | `scripts/check-doc-size.sh` · `scripts/check-doc-staleness.sh` |
| Tests | `bin/rails test` (minitest, parallel; system tests in `test/system/`, Capybara + Chrome) — **not runnable safely today**, see Trap 2 |

- **Lint baseline:** rubocop is not clean repo-wide (mostly `Metrics` and long-line noise). The bar is
  no *new* offenses on the lines you touched. The rule that bites is `Layout/LineLength` at 120.
  Don't rename `is_bot_request?` to please the `Naming/PredicatePrefix` cop (Julian, 2026-05-24).
- **Boot check** (`scripts/check-boot.rb`): the app eager-loads, `application.css` compiles, and every
  ERB view compiles. No database, no browser. It does not prove a page renders right.
- **Test suite state:** the admin scaffold tests (`test/controllers/admin/*`, `test/system/admin/*`)
  call fixtures like `admin_projects(:one)` that don't exist, so they all error. Repair or remove is
  an open call in `status.md`.

## Walking a route
After the boot check, open each changed page at desktop width and at phone width (~375px). The
featured carousel and the photo viewer are the pages that break on phones.

Claude's Chrome tool cannot reach phone width: the viewport stayed at 1470px whatever
`resize_window` did (May 2026). So Claude walks desktop and checks mobile in the markup and CSS,
and the phone-width look is Julian's check in Chrome's device toolbar. Say which one was done.
