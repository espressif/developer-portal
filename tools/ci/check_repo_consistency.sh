#!/usr/bin/env bash
set -euo pipefail


###############################################################################
# CONFIGURATION
###############################################################################

TARGET_REPO_URL="${TARGET_REPO_URL:-https://github.com/espressif/developer-portal.git}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"

DYNAMIC_BLOCK_FILE="layouts/shortcodes/dynamic-block.html"


###############################################################################
# UTILITIES & INSTALLATION HELPERS
###############################################################################

banner() {
  echo
  echo "=========================================="
  echo "$1"
  echo "=========================================="
}


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
# FUNCTIONS
###############################################################################

check_forbidden_filetypes() {
  local base_ref="$1"

  local base_commit
  base_commit="$(git rev-parse "$base_ref")"

  echo
  echo "Base commit: $base_commit"

  # Forbidden extensions (regex-friendly, case-insensitive)
  # Add more by simply extending the list below
  local image_ext="jpe?g|png"
  local binary_ext="bin|img"

  # Get added/modified files
  local changed_files
  changed_files=$(git diff --name-only --diff-filter=AM "$base_ref"...HEAD)

  # Find forbidden images
  local forbidden_images
  forbidden_images=$(echo "$changed_files" | grep -iE "\.($image_ext)$" || true)

  # Find forbidden binaries
  local forbidden_binaries
  forbidden_binaries=$(echo "$changed_files" | grep -iE "\.($binary_ext)$" || true)

  local error=0

  # Report images
  if [ -n "$forbidden_images" ]; then
    echo
    echo "❌ The image file types listed below are not allowed."
    echo "   Please convert your images to WebP format."
    echo "   More info: https://developer.espressif.com/pages/contribution-guide/writing-content/#use-webp-for-raster-images"
    echo "$forbidden_images"
    error=1
  else
    echo
    echo "No forbidden image file types found."
  fi

  # Report binary files
  if [ -n "$forbidden_binaries" ]; then
    echo
    echo "❌ The following binary file types are not allowed in the repository:"
    echo "$forbidden_binaries"
    error=1
  else
    echo
    echo "No forbidden binary file types found."
  fi

  return $error
}

check_dynamic_block_localmode() {
  if grep -q '{{ *\$localMode *:= *true *}}' "$DYNAMIC_BLOCK_FILE"; then
    echo
    echo "❌ In $DYNAMIC_BLOCK_FILE, localMode is set to \"true\"."
    echo "   Set it to \"false\"."
    echo "   More info: https://developer.espressif.com/pages/contribution-guide/dynamic-content/#test-dynamic-content"
    return 1
  fi

  echo
  echo "In $DYNAMIC_BLOCK_FILE, localMode is correctly set to \"false\"."
  return 0
}


###############################################################################
# MAIN
###############################################################################

overall_error=0

banner "🔁 Fetching target repo..."

ensure_target_remote
BASE_REF="$(resolve_base_ref)"


banner "🔎 Checking for forbidden filetypes..."

check_forbidden_filetypes "$BASE_REF" || overall_error=1


banner "🔎 Checking dynamic block localmode..."

check_dynamic_block_localmode || overall_error=1


echo
echo "=========================================="
if [ "$overall_error" -ne 0 ]; then
  echo "❌ One or more validation steps failed."
  exit 1
else
  echo "✅ All validation steps passed."
fi
