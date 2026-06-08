#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# CONFIGURATION
###############################################################################

TARGET_REPO_URL="${TARGET_REPO_URL:-https://github.com/espressif/developer-portal.git}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
TEMP_ROOT="temp_ci"
REQUIRED_TOOLS=(
    git
    jq
    hugo
)

REMOTE_ADDED=false
TEMP_DIR=""


###############################################################################
# UTILITIES & INSTALLATION HELPERS
###############################################################################

banner() {
  echo
  echo "=========================================="
  echo "$1"
  echo "=========================================="
}

check_required_tools() {
  local missing=()

  for tool in "${REQUIRED_TOOLS[@]}"; do
      if ! command -v "$tool" >/dev/null 2>&1; then
          missing+=("$tool")
      fi
  done

  if ((${#missing[@]} > 0)); then
      echo
      echo "ERROR: Missing required tools:" >&2
      for tool in "${missing[@]}"; do
          echo "  - $tool" >&2
      done
      return 1
  fi

  echo
  echo "All required tools are installed."
  return 0
}

check_git_submodules() {
  # If there is no .gitmodules file, nothing to check
  if [[ ! -f .gitmodules ]]; then
      return 0
  fi

  local missing=()

  # Extract each submodule path defined in .gitmodules
  while IFS='=' read -r key value; do
    # Normalize key and value
    key=${key//[[:space:]]/}
    value=${value//[[:space:]]/}

    if [[ "$key" == "path" ]]; then
        if [[ ! -d "$value" || ! -d "$value/.git" && ! -f "$value/.git" ]]; then
            missing+=("$value")
        fi
    fi
  done < <(grep '=' .gitmodules)

  # Report missing or uninitialized submodules
  if ((${#missing[@]} > 0)); then
    echo
    echo "ERROR: Missing or uninitialized git submodules:" >&2
    for path in "${missing[@]}"; do
        echo "  - $path" >&2
    done
    echo
    echo "Run: git submodule update --init --recursive" >&2
    return 1
  fi

  echo "All git submodules are present and initialized."
  return 0
}


###############################################################################
# CLEANUP HANDLING
###############################################################################

cleanup() {
  if [ -d "$TEMP_ROOT" ]; then
    rm -rf "$TEMP_ROOT"
  fi

  if [ "$REMOTE_ADDED" = "true" ]; then
    git remote remove target >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT


###############################################################################
# GIT + BASELINE
###############################################################################

ensure_target_remote() {
  if ! git remote get-url target >/dev/null 2>&1; then
    git remote add target "$TARGET_REPO_URL"
    REMOTE_ADDED=true
  fi

  git fetch target "$TARGET_BRANCH"
}

resolve_base_ref() {
    if [[ -n "${GITHUB_BASE_REF:-}" ]]; then
        echo "origin/${GITHUB_BASE_REF}"
    elif [[ -n "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME:-}" ]]; then
        echo "target/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}"
    else
        echo "target/${TARGET_BRANCH}"
    fi
}


###############################################################################
# FILE COLLECTION
###############################################################################

collect_changed_files() {
  local base_ref="$1"

  local base_commit
  base_commit="$(git rev-parse "$base_ref")"

  echo
  echo "Base commit: $base_commit"

  mkdir -p "$TEMP_ROOT"
  TEMP_DIR="$(mktemp -d "${TEMP_ROOT}/check-article-details.XXXXXX")"

  git diff --name-only "$base_ref"...HEAD \
    | grep -E '^content/(blog|workshops)/.*' \
    > "$TEMP_DIR/files-changed.txt" || true

  echo
  echo "List of changed content files:"
  cat "$TEMP_DIR/files-changed.txt"

  if [[ -s "$TEMP_DIR/files-changed.txt" ]]; then
    check_for_spaces_in_paths "$TEMP_DIR/files-changed.txt" || exit 1
    check_changed_filenames_and_paths "$TEMP_DIR/files-changed.txt" || overall_error=1
  fi

  git diff --name-only --diff-filter=A "$base_ref"...HEAD \
    | grep -E '^content/blog/.*/index.md$' \
    > "$TEMP_DIR/index-added.txt" || true

  echo
  echo "List of added index files:"
  cat "$TEMP_DIR/index-added.txt"

  git diff --name-status "$base_ref"...HEAD \
    | grep -E '^[MR][0-9]*[[:space:]]+content/(blog|workshops)/.*/index\.md' \
    | awk '
        $1=="M" {print $2}
        $1 ~ /^R/ && $1!="R100" {print $3}
      ' > "$TEMP_DIR/index-updated.txt" || true

  echo
  echo "List of updated index files:"
  cat "$TEMP_DIR/index-updated.txt"

  git diff --name-status "$base_ref"...HEAD \
    | grep -E '^[MR][0-9]*[[:space:]]+content/(blog|workshops)/.*/index\.md' \
    | grep '^R' \
    | awk '
      $2 ~ /(\/|^)_?index\.md$/ || $3 ~ /(\/|^)_?index\.md$/ {
          print $2 " > " $3
      }
    ' > "$TEMP_DIR/folders-renamed.txt" || true

  echo
  echo "List of renamed articles:"
  cat "$TEMP_DIR/folders-renamed.txt" \
    | sed -E 's:\/_?index\.md::g'
}


###############################################################################
# FILE NAME VERIFICATION
###############################################################################

check_for_spaces_in_paths() {
  local input_file="$1"
  local job_error=0
  local bad=""

  while IFS= read -r line; do
    if [[ "$line" == *" "* ]]; then
      job_error=1
      bad+="$line"$'\n'
      echo $bad
    fi
  done < "$input_file"

  if [[ $job_error -eq 1 ]]; then
    echo
    echo "❌ Spaces are not allowed. Please remove spaces in the following file paths:"
    printf "%s" "$bad"
    return 1
  else
    echo
    echo "No spaces found it file paths."
  fi

  return 0
}

check_changed_filenames_and_paths() {
  local input_file="$1"

  local job_error=0
  local saw_index_md=0
  local bad_files=""
  local bad_chars=""

  bad_chars='_:;,$%#@!?'

  while IFS= read -r line; do
    # Track if this path ends with _index*.md
    if [[ "$line" == */_index*.md ]]; then
      saw_index_md=1
    fi

    # Remove trailing _index*.md if present
    if [[ "$line" == */_index*.md ]]; then
      cleaned="${line%/_index*.md}"
    else
      cleaned="$line"
    fi

    # If the cleaned path still has an underscore, it's invalid
    if [[ "$cleaned" =~ [$bad_chars] ]]; then
      bad_files+="$line"$'\n'
    fi
  done < "$input_file"

  if [[ -n "$bad_files" ]]; then
    echo
    echo "❌ Remove underscores and unusual characters ($bad_chars) in these paths:"
    if [[ "$saw_index_md" -eq 1 ]]; then
      echo "   (filename \"_index*.md\" is allowed)"
    fi
    printf "%s" "$bad_files"
    job_error=1
  else
    echo "No bad characters found in filenames and paths."
  fi

  if [ "$job_error" -eq 0 ]; then
    return 0
  fi

  return 1
}


###############################################################################
# METADATA EXTRACTION (ADDED ARTICLES)
###############################################################################

extract_added_metadata() {
  echo
  echo "Extracting added article metadata..."

  if [[ ! -s "$TEMP_DIR/index-added.txt" ]]; then
      echo "No added index files."
      return 1
  fi

  local json_out="$TEMP_DIR/article_data.json"
  local jq_input="{}"

  while IFS= read -r index_file; do
    local relative_path
    local ARTICLE_ID
    local FOLDER_YM
    local ARTICLE_DATE
    local ARTICLE_YM
    local ARTICLE_SUMMARY_RAW
    local ARTICLE_SUMMARY

    relative_path=$(dirname "${index_file#content/blog/}")
    # Extract article_id - last directory of the path
    ARTICLE_ID=$index_file
    FOLDER_YM=""

    if [[ "$relative_path" =~ ^([0-9]{4})/([0-9]{2})/[^/]+$ ]]; then
      FOLDER_YM="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
    fi

    ARTICLE_DATE=$(awk '/^date:/ { gsub(/["'\'']/, "", $2); print $2 }' "$index_file")
    [[ -z "$ARTICLE_DATE" ]] && { echo "No valid date in $index_file"; continue; }

    ARTICLE_YM="${ARTICLE_DATE:0:7}"

    ARTICLE_SUMMARY_RAW=$(awk '/^summary:/ { $1=""; gsub(/^[: \t'\''"]+|["'\'' \t]+$/, "", $0); print; exit }' "$index_file")

    # If summary is empty or not found, set to empty string
    ARTICLE_SUMMARY_RAW=${ARTICLE_SUMMARY_RAW:-""}

    # Extract up to first 5 words if ARTICLE_SUMMARY_RAW is not empty
    if [[ -n "$ARTICLE_SUMMARY_RAW" ]]; then
      read -r -a words <<< "$ARTICLE_SUMMARY_RAW"
      ARTICLE_SUMMARY="${words[0]:-}"
      for i in {1..4}; do
        [[ -n "${words[i]:-}" ]] && ARTICLE_SUMMARY+=" ${words[i]}"
      done
    else
      ARTICLE_SUMMARY=""
    fi

    jq_input=$(jq \
      --arg id "$ARTICLE_ID" \
      --arg fym "$FOLDER_YM" \
      --arg aym "$ARTICLE_YM" \
      --arg ad "$ARTICLE_DATE" \
      --arg asum "$ARTICLE_SUMMARY" \
      '.[$id] = {
        folder_ym: $fym,
        article_ym: $aym,
        article_date: $ad,
        article_summary: $asum
      }' <<< "$jq_input")
  done < "$TEMP_DIR/index-added.txt"

  echo "$jq_input" > "$json_out"

  echo "Metadata extracted:"
  cat "$json_out"
}


###############################################################################
# VALIDATION OF ADDED ARTICLES
###############################################################################

validate_added_articles() {
  echo
  echo "Validating added articles..."

  local article_data="$TEMP_DIR/article_data.json"
  [[ ! -f "$article_data" ]] && { echo "No metadata."; return 1; }

  local current_ym current_date
  # Get current year and month as strings
  current_ym="$(date +%Y-%m)"
  current_date="$(date +%Y-%m-%d)"

  local job_error=0
  local YM_REGEX='^[0-9]{4}-[0-9]{2}$'
  local DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
  local folder_ym article_ym article_date article_summary

  while read -r article_key; do

    local article_error=0

    folder_ym="$(jq -r --arg key "$article_key" '.[$key].folder_ym' "$article_data")"
    article_ym="$(jq -r --arg key "$article_key" '.[$key].article_ym' "$article_data")"
    article_date="$(jq -r --arg key "$article_key" '.[$key].article_date' "$article_data")"
    article_summary="$(jq -r --arg key "$article_key" '.[$key].article_summary' "$article_data")"

    echo
    echo "Article: $article_key"

    # Report if folder year or month is empty and skip
    if ! [[ "$folder_ym" =~ $YM_REGEX ]]; then
      echo "❌ Wrong folder."
      echo "   Move the article to a present or future 'content/blog/YYYY/MM/' folder and add a matching publishing date in the article's YAML header."
      article_error=1
    fi

    # Report if article date format is invalid and skip
    if [[ ! "$article_date" =~ $DATE_REGEX ]]; then
      echo "❌ Invalid date format in the article's YAML header: $article_date."
      echo "   Expected: YYYY-MM-DD."
      article_error=1
    fi

    # Skip if folder year/month or article date are empty,
    # or the following code will have issues
    if [ "$article_error" -eq 1 ]; then
      job_error=1
      continue
    fi


    # Check article details against this decision tree
    #
    # Is folder_ym != article_ym?
    # ├── Yes → Warn: folder_ym and article_ym must match
    # └── No →
    #     Is folder_ym < current_ym?
    #     ├── Yes → Warn: folder is in the past
    #     └── No →
    #         Is folder_ym > current_ym?
    #         ├── Yes → OK (scheduled for a future month)
    #         └── No  →  # folder_ym == current_ym
    #             Is article_date < current_date?
    #             ├── Yes → Warn: article date is in the past
    #             └── No  → OK
    if [ "$folder_ym" != "$article_ym" ]; then
      echo "❌ Article's YYYY/MM folder and publishing date are inconsistent: $folder_ym and $article_date."
      echo "   Move the article to a present or future 'content/blog/YYYY/MM/' folder and add a matching publishing date in the article's YAML header."
      article_error=1
    else
      if [ "$folder_ym" \< "$current_ym" ]; then
        echo "❌ Wrong folder: $folder_ym."
        echo "   Move the article to a present or future 'content/blog/YYYY/MM/' folder and add a matching publishing date in the article's YAML header."
        article_error=1
      elif [ "$folder_ym" \> "$current_ym" ]; then
        # Folder is a future month -> OK
        :
      else
        # folder_ym == current_ym
        if [ "$article_date" \< "$current_date" ]; then
          echo "❌ Publishing date in the article's YAML header is in the past: $article_date."
          echo "   Once the article is approved, update the date to a present or future day and make sure it matches the article's 'content/blog/YYYY/MM/' folder."
          article_error=1
        fi
      fi
    fi

    # Report if article summary is not provided
    if [ -z "$article_summary" ]; then
      echo "❌ Missing summary."
      echo "   Add the summary in the article's YAML header:"
      echo "   summary: \"This is my summary.\""
      article_error=1
    elif [[ "$article_summary" == Replace\ it\ with* ]]; then
      echo "❌ Placeholder summary found."
      echo "   Update the summary in the article's YAML header."
      article_error=1
    fi

    if [ "$article_error" -eq 0 ]; then
      echo "Article path and YAML frontmatter details are correct."
    else
      job_error=1
    fi
  done < <(jq -r 'keys[]' "$article_data")

  if [ "$job_error" -eq 0 ]; then
    return 0
  fi

  return 1
}

find_trailing_spaces() {
  echo
  echo "Looking for trailing whitespaces..."

  local job_error=0

  while IFS= read -r file; do
    # Skip empty lines
    [[ -z "$file" ]] && continue

    # Check if file exists
    if [[ ! -f "$file" ]]; then
      echo "Warning: File not found: $file"
      continue
    fi

    # Count lines with trailing spaces
    count=$(grep -c '[[:blank:]]$' "$file")

    # Report only if there are trailing spaces
    if [[ "$count" -gt 0 ]] 2>/dev/null; then
      job_error=1
      echo
      echo "❌ Lines end with extra spaces or tabs."
      echo "   Remove trailing whitespaces from (use <br> where needed):"
      echo "   $file -- $count line(s) in total."
    fi
  done < "$TEMP_DIR/index-added.txt"

  if [ "$job_error" -eq 0 ]; then
    return 0
  fi

  return 1
}


###############################################################################
# FEATURE ASSET VALIDATION
###############################################################################

validate_feature_assets() {
  echo
  echo "Validating featureAsset presence..."

  local job_error=0
  local INDEX_LIST="${TEMP_DIR}/index-added.txt"
  local index_file path

  while IFS= read -r index_file; do
    [[ -z "$index_file" ]] && continue
    path=$(awk '/^featureAsset:/ { gsub(/["'\'' ]/, "", $2); print $2; exit }' "$index_file")
    [[ "$path" == img/* ]] && continue
    echo
    echo "Article: $index_file"
    echo "❌ Incorrect use of featureAsset in front matter."
    echo "   Use it only to include a shared image from \"assets/img/featured/\"."
    echo "   Otherwise, place your article image alongside index.md and ensure its name includes \"feature\"."
    job_error=1
  done < "$INDEX_LIST"

  if [[ $job_error -eq 0 ]]; then
    echo "No issues found."
  fi
  return $job_error
}


###############################################################################
# AUTHOR VALIDATION (HUGO BUILD)
###############################################################################

validate_author_presence() {
  echo
  echo "Validating author presence..."

  local job_author_error=0
  local HUGO_TEMP_CONTENT="${TEMP_DIR}/content"
  local INDEX_LIST="${TEMP_DIR}/index-added.txt"

  while IFS= read -r line; do
    dir="$(dirname "$line")"
    mkdir -p "$TEMP_DIR/$dir"
    cp -r "$dir"/. "$TEMP_DIR/$dir/"
  done < "$INDEX_LIST"

  # Build folders with new articles only
  hugo \
    --environment preview \
    --contentDir "$HUGO_TEMP_CONTENT" \
    > /dev/null 2>&1

  # Check if html files were built successfully
  while IFS= read -r md_file; do
    local relative_path
    local html_path
    # Strip content/ and .md
    relative_path="${md_file#content/}"
    html_path="public/${relative_path%.md}.html"

    echo
    echo "Article: $html_path"

    if [[ ! -f "$html_path" ]]; then
      echo "❌ File not found: $html_path"
      job_author_error=1
    fi

    # Scan html div blocks for presence of author and author-extra
    # classes; their presence ensures the presence of author entry
    author_divs=$(grep -oE '<div[^>]+class="[^"]*\bauthor\b[^"]*"' "$html_path" 2>/dev/null || true)

    if [[ -z "$author_divs" ]]; then
      echo "❌ Author not found"
      job_author_error=1
    elif echo "$author_divs" | grep -q '\bauthor-extra\b'; then
      echo "Non-default author is found"
    else
      echo "Default author is found"
    fi
  done < "$INDEX_LIST"

  if [ "$job_author_error" -eq 0 ]; then
    return 0
  fi

  return 1
}


###############################################################################
# UPDATED ARTICLES VALIDATION
###############################################################################

collect_updated_articles_body_only() {
  local base_ref="$1"
  local output_file="${3:-$TEMP_DIR/index-updated-body.txt}"

  > "$output_file"  # Clear output file

  while IFS= read -r file; do
    # Skip empty lines
    [[ -z "$file" ]] && continue

    # Get the diff for this specific file
    local diff_output
    diff_output=$(git diff -U0 "$base_ref"...HEAD -- "$file")

    # Flag to track if we found changes in frontmatter
    local has_frontmatter_changes=false

    # Parse the diff output looking for change hunks
    while IFS= read -r line; do
      # Look for hunk headers like @@ -1,5 +1,5 @@
      if [[ "$line" =~ ^@@\ -([0-9]+) ]]; then
        local start_line="${BASH_REMATCH[1]}"

        # Get the frontmatter end line from the original file
        local frontmatter_end
        frontmatter_end=$(git show "$base_ref:$file" | awk '
          BEGIN { count=0 }
          /^---$/ { count++; if(count==2) { print NR; exit } }
        ')

        # If we couldn't find frontmatter end, assume no frontmatter
        [[ -z "$frontmatter_end" ]] && frontmatter_end=0

        # If this hunk starts within the frontmatter section (line 1 to frontmatter_end)
        if [[ $start_line -le $frontmatter_end ]]; then
          has_frontmatter_changes=true
          break
        fi
      fi
    done <<< "$diff_output"

    # If no frontmatter changes detected, add to output
    if [[ "$has_frontmatter_changes" == false ]]; then
      echo "$file" >> "$output_file"
    fi
  done < "$TEMP_DIR/index-updated.txt"

  echo
  echo "List of updated articles with body-only changes:"
  cat "$output_file"
}

validate_updated_articles_lastmod() {
  echo
  echo "Validating updated articles..."

  local job_error=0
  local DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'

  while IFS= read -r index_file; do
    local article_error=0
    local ARTICLE_DATE
    local LASTMOD_DATE
    local ARTICLE_DATE_ONLY

    ARTICLE_DATE=$(awk '/^date:/ { gsub(/["'\'']/, "", $2); print $2 }' "$index_file")
    LASTMOD_DATE=$(awk '/^lastmod:/ { gsub(/["'\'']/, "", $2); print $2 }' "$index_file")
    ARTICLE_DATE_ONLY="${ARTICLE_DATE:0:10}"

    local FILE_MOD_DATE
    FILE_MOD_DATE=$(stat -c '%y' "$index_file" 2>/dev/null | cut -d' ' -f1 || stat -f '%Sm' -t '%Y-%m-%d' "$index_file")

    echo
    echo "Article: $index_file"

    if [ -z "$ARTICLE_DATE_ONLY" ]; then
      echo "❌ Missing date."
      echo "   Add date in the article's YAML header:"
      echo "   date: YYYY-MM-DD"
      article_error=1
    fi

    if [[ ! "$LASTMOD_DATE" =~ $DATE_REGEX ]]; then
      if [ -z "$LASTMOD_DATE" ]; then
        echo "❌ Missing lastmod."
        echo "   Add lastmod in the article's YAML header:"
        echo "   lastmod: YYYY-MM-DD"
      else
        echo "❌ Invalid lastmod format in the article's YAML header: $LASTMOD_DATE."
        echo "   Expected: YYYY-MM-DD."
      fi
      article_error=1
    fi

    if [ "$article_error" -eq 0 ]; then
      if [ "$LASTMOD_DATE" \< "$ARTICLE_DATE_ONLY" ]; then
        echo "❌ lastmod is earlier than date: $LASTMOD_DATE < $ARTICLE_DATE_ONLY."
        echo "   Update lastmod to the same day or later than date."
        article_error=1
      fi
    fi

    if [ "$article_error" -eq 0 ] && [ -n "$FILE_MOD_DATE" ]; then
      # Calculate days difference (allowing up to 3 days lag)
      local days_diff
      days_diff=$(( ( $(date -d "$FILE_MOD_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$FILE_MOD_DATE" +%s) - $(date -d "$LASTMOD_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$LASTMOD_DATE" +%s) ) / 86400 ))

      if [ "$days_diff" -gt 3 ]; then
        echo "❌ lastmod is outdated: $LASTMOD_DATE (file modified: $FILE_MOD_DATE)."
        echo "   Update lastmod to reflect the recent changes (within 3 days of modification)."
        article_error=1
      fi
    fi

    if [ "$article_error" -eq 0 ]; then
      echo "lastmod date validated successfully."
    else
      job_error=1
    fi
  done < "$TEMP_DIR/index-updated-body.txt"

  if [ "$job_error" -eq 0 ]; then
    return 0
  fi

  return 1
}

validate_aliases_in_renamed_articles() {
  echo
  echo "Validating aliases in renamed articles for URL redirects..."

  local job_error=0

  while IFS='>' read -r old_name new_name; do
    old_name=$(echo "$old_name" | xargs)   # trim spaces
    new_name=$(echo "$new_name" | xargs)

    index_file="$new_name"

    echo
    echo "Article: $index_file"

    if [ ! -f "$index_file" ]; then
      echo "❌ index.md not found in $new_name"
      job_error=1
    fi

    alias_path=$(dirname "$old_name" | sed 's:^content::')

    if ! awk -v alias="$alias_path" '
        # Detect aliases: section
        $0 ~ /^aliases:/ { in_aliases=1; next }

        # Stop when a new YAML root key starts
        in_aliases && $0 ~ /^[A-Za-z0-9_-]+:/ { in_aliases=0 }

        # Check only bullet lines: "- something"
        in_aliases && $0 ~ /^[[:space:]]*-/ {
            if (index($0, alias) > 0) {
                found=1
            }
        }

        END { exit(!found) }
    ' "$index_file"
    then
        echo "❌ Missing or incorrect alias for old URL redirects"
        echo "   Expected in YAML header:"
        echo "aliases:"
        echo "  - $alias_path"
        job_error=1
    else
        echo "Alias validated successfully."
    fi
  done < "$TEMP_DIR/folders-renamed.txt"

  if [ "$job_error" -eq 0 ]; then
    return 0
  fi

  return 1
}

###############################################################################
# MAIN
###############################################################################

init_error=0

banner "🛠️ Verifying requirements..."

check_required_tools || init_error=1
check_git_submodules || init_error=1

if [ "$init_error" -ne 0 ]; then
  echo
  echo "❌ Required tools or submodules are missing."
  exit 1
fi

overall_error=0

banner "🔁 Fetching target repo..."

ensure_target_remote
BASE_REF="$(resolve_base_ref)"

banner "🔎 Checking changed filenames and paths..."

collect_changed_files "$BASE_REF"

banner "🔎 Checking added files..."

if [[ -s "$TEMP_DIR/index-added.txt" ]]; then
  extract_added_metadata || overall_error=1
  validate_added_articles || overall_error=1
  find_trailing_spaces || overall_error=1
  validate_author_presence || overall_error=1
  validate_feature_assets || overall_error=1
else
  echo "No added index files."
fi

banner "🔎 Checking updated files..."

if [[ -s "$TEMP_DIR/index-updated.txt" ]]; then
  collect_updated_articles_body_only "$BASE_REF"
  validate_updated_articles_lastmod || overall_error=1
fi

if [[ -s "$TEMP_DIR/folders-renamed.txt" ]]; then
  validate_aliases_in_renamed_articles || overall_error=1
fi

echo
echo "=========================================="
if [ "$overall_error" -ne 0 ]; then
  echo "❌ One or more validation steps failed."
  exit 1
else
  echo "✅ All required checks passed."
fi
