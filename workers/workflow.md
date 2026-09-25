# How a task runs — workflow (Layer 2)

ELI5: agree the plan → build it → one fresh checker looks at it → commit and push once.
This replaces the old overseer brief. A session wears one hat at a time (engineer, uiux, writer);
this file is the order the steps happen in. There are no parallel role sessions.

## Inputs
| What | Where | Why |
|---|---|---|
| Where things stand | `../claude-talk.md` (if it has entries) · `../docs/status.md` | Don't redo or re-ask |
| Always-true facts + where to look | `../CLAUDE.md` · `../CONTEXT.md` | The map |
| Facts for this topic | the `docs/` file the map points to | One home per fact |
| Rules for this area | `<hat>.md` in this folder | The hat's checklist |

## Steps
1. **Start from a clean `master`.** Julian and Claude are the only people on this repo, so work
   happens on `master` directly (Julian, 2026-09-25). No worktrees or feature branches unless
   Julian asks for one. `git -C <repo> status` first: if there are changes you did not make, ask
   before touching them.
2. **Agree the plan.** Say it in a few lines and get Julian's yes. Write a spec (in
   `../docs/specs/`) only for big or risky work, and only if Julian wants one.
3. **Build**, wearing the right hat. Switch hats as the work moves (engineer → uiux → writer is
   the usual order for a new page: scaffold, then look, then words).
4. **No commits mid-task.** Commit at the end, once the checker is done.
5. **Run the gates once, at the end**, sized to risk (table below). Commands and the local-setup
   gotchas: `../docs/dev.md`.
6. **One independent checker.** Every session that changed files ends with exactly one fresh
   checker subagent using `checker.md`. Its brief must restate the shell rule (no `cd X && cmd`,
   absolute paths, prefer Read over `cat`). The checker reports; this session fixes what it
   finds and re-runs the affected gates. A second checker only after asking Julian.
7. **Ship once.** Drain `../claude-talk.md` (open items → `../docs/status.md`, lasting facts →
   their `docs/` file), wipe its entries, commit in Conventional Commits format, push to `origin`
   once. Stage your own files by name, never `git add -A` on a tree with someone else's changes.
   **Deploying (`git push heroku master`) only at Julian's go.**
8. **Report.** A short ELI5 answer. Details only if Julian asks.

When a call is Julian's, ask with options, a recommendation, and the trade-off, never an open
"what do you want?". A go for one action is not a go for the next one.

## Gates and checker depth, by risk
| Risk | Examples | Gates (once, at the end) | Checker depth |
|---|---|---|---|
| Safety | admin auth, contact form + spam layers, event signup/capacity, migrations, data loss | rubocop · boot check · `bin/rails test` once the suite is repaired (`../docs/dev.md`) · walk the changed routes (desktop + phone width) | full `checker.md` + try to break it |
| Normal | pages, styling, features, fixes | rubocop · boot check · walk the changed routes (desktop + phone width) | `checker.md` sections the change touches |
| Docs / copy | docs, wording | `../scripts/check-doc-size.sh` · `../scripts/check-doc-staleness.sh` (+ boot check if a view changed) | nothing dropped · no contradictions · paths resolve |

## Doc rules
- **`CLAUDE.md` never grows without Julian's OK**, not even by one pointer line. A Claude hook
  blocks it and `../scripts/check-doc-size.sh` fails the commit.
- New facts go in a `docs/` file. A new file gets its pointer in `CONTEXT.md`, not `CLAUDE.md`.
- Change a fact where it lives and delete the stale copy. Never append a correction next to it.
- Code is the tie-breaker: check a value against the code before writing it into a doc.
- Process stories (checker rounds, what was tried) go in the commit message, not in lasting docs.

## Outputs
| What | Where |
|---|---|
| Code and tests | `master`, pushed once |
| Open items | `../docs/status.md` |
| New lasting facts | the topic file in `docs/` |
| Session notes | `../claude-talk.md` (wiped on push) |
