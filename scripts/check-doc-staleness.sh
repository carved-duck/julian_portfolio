#!/usr/bin/env bash
#
# Doc staleness guard. Fails if a live doc names a file or setting that no longer exists.
# Each identifier below is dead for good, so any mention in a live doc is stale by definition.
# Add one only when it can never be legitimate again; if it can, rely on the edit-in-place habit.
#
# Usage: scripts/check-doc-staleness.sh
set -uo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo; skipping doc-staleness check"; exit 0; }
cd "$root" || exit 1

# identifier | why it is dead
DEAD=(
  "comprehensive_test.rb|deleted 2026-05-24; event logic has no standalone script now"
  "claude-checker.md|renamed to workers/checker.md 2026-09-25"
  "overseer.md|replaced by workers/workflow.md 2026-09-25"
  "SEO_IMPROVEMENTS.md|moved to docs/seo.md"
  "SPAM_PROTECTION.md|moved to docs/spam-protection.md"
  "GOOGLE_ANALYTICS_ID|GA4 id lives in Rails credentials as google_analytics_id, not an env var"
  "_featured_carousel|the home carousel was replaced by the slider 2026-09-25 (docs/frontend.md)"
)

# Live docs only. docs/specs/ is dated history and may name old things.
live_docs=$(ls CLAUDE.md CONTEXT.md README.md docs/*.md workers/*.md 2>/dev/null)

status=0
for entry in "${DEAD[@]}"; do
  id="${entry%%|*}"
  why="${entry#*|}"
  # shellcheck disable=SC2086
  hits=$(grep -nF -- "$id" $live_docs 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "✖ doc-staleness: '$id' is dead ($why):" >&2
    echo "$hits" | sed 's/^/    /' >&2
    status=1
  fi
done

[ "$status" -eq 0 ] && echo "doc-staleness: OK"
exit "$status"
