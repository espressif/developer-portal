#!/usr/bin/env bash
# Collect the site paths of articles touched by a pull request.
#
# Reads the list of files changed between the base and head commits and maps
# each one to the URL path of the article it belongs to. Blog posts are leaf
# bundles, so the article root is the directory holding index.md. Workshops are
# branch bundles with sub-pages, so the article root is the top-level workshop
# directory.
#
# Usage: collect_pr_articles.sh <base-sha> <head-sha> <output-file>

set -euo pipefail

BASE_SHA="${1:?base sha required}"
HEAD_SHA="${2:?head sha required}"
OUT_FILE="${3:?output file required}"

: > "$OUT_FILE"

if ! MERGE_BASE="$(git merge-base "$BASE_SHA" "$HEAD_SHA" 2>/dev/null)"; then
  if git rev-parse --verify --quiet "${BASE_SHA}^{commit}" >/dev/null; then
    MERGE_BASE="$BASE_SHA"
  else
    echo "Base commit $BASE_SHA unavailable; no article list produced."
    exit 0
  fi
fi

git diff --name-only --diff-filter=d "$MERGE_BASE" "$HEAD_SHA" \
  | while IFS= read -r file; do
      case "$file" in
        content/blog/*)
          # Strip the file name and walk up to the directory holding index.md.
          dir="${file%/*}"
          while [ "$dir" != "content/blog" ] && [ "$dir" != "content" ] && [ -n "$dir" ]; do
            if [ -f "$dir/index.md" ] || [ -f "$dir/_index.md" ]; then
              printf '%s/\n' "${dir#content/}"
              break
            fi
            dir="${dir%/*}"
          done
          ;;
        content/workshops/*)
          # Keep only the top-level workshop directory.
          rest="${file#content/workshops/}"
          workshop="${rest%%/*}"
          [ "$workshop" = "$rest" ] && continue
          printf 'workshops/%s/\n' "$workshop"
          ;;
      esac
    done \
  | sort -u > "$OUT_FILE"

echo "Articles touched by this PR:"
cat "$OUT_FILE"
