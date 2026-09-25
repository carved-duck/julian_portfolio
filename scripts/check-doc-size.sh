#!/usr/bin/env bash
#
# Doc size guard. CLAUDE.md and CONTEXT.md are the map every AI session loads, so they stay small
# (2026-09-25). CLAUDE.md is capped at its current size: frozen. CONTEXT.md is the router, so its cap
# leaves room for new "task → file" rows but not for facts. If Julian approves more growth, raise the
# cap here in the same commit so it is a reviewable diff. New facts go in a docs/ file instead.
#
# Usage: scripts/check-doc-size.sh
set -uo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo; skipping doc-size check"; exit 0; }
cd "$root" || exit 1

# file:max_lines:max_words
CAPS=(
  "CLAUDE.md:51:457"
  "CONTEXT.md:45:450"
)

status=0
for entry in "${CAPS[@]}"; do
  IFS=: read -r f max_lines max_words <<<"$entry"
  if [ ! -f "$f" ]; then
    echo "✖ doc-size: $f is missing" >&2
    status=1
    continue
  fi
  lines=$(wc -l < "$f" | tr -d ' ')
  words=$(wc -w < "$f" | tr -d ' ')
  if [ "$lines" -gt "$max_lines" ] || [ "$words" -gt "$max_words" ]; then
    echo "✖ doc-size: $f is $lines lines / $words words (cap $max_lines lines / $max_words words)." >&2
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo "" >&2
  echo "CLAUDE.md and CONTEXT.md only grow when Julian says so. Put the new fact in a docs/ file and" >&2
  echo "point to it from CONTEXT.md. If Julian approved the growth, raise the cap in this script." >&2
else
  echo "doc-size: OK"
fi
exit "$status"
