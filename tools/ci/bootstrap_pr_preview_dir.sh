#!/usr/bin/env bash
# Copy prod-copy/persist/ to pr$PR_NUMBER/persist/ for PR previews.
# Hugo deploy excludes persist/**; dynamic JSON and assets live under this prefix.
# Requires AWS CLI credentials in env.
set -euo pipefail

: "${PR_NUMBER:?PR_NUMBER must be set}"
: "${PREVIEW_AWS_BUCKET_NAME:?PREVIEW_AWS_BUCKET_NAME must be set}"

PERSIST_SRC="prod-copy/persist/"
PERSIST_DEST="pr${PR_NUMBER}/persist/"

SRC_COUNT="$(aws s3api list-objects-v2 \
  --bucket "$PREVIEW_AWS_BUCKET_NAME" \
  --prefix "$PERSIST_SRC" \
  --max-keys 1 \
  --query 'KeyCount' \
  --output text)"

if [ "${SRC_COUNT:-0}" = "0" ] || [ -z "${SRC_COUNT}" ] || [ "${SRC_COUNT}" = "None" ]; then
  echo "prod-copy/persist/ is empty or missing; cannot sync persist data for PR preview."
  echo "Run the cron production deploy to populate prod-copy/ first."
  exit 1
fi

echo "Syncing persist data: ${PERSIST_SRC} → ${PERSIST_DEST}"

aws s3 sync \
  "s3://${PREVIEW_AWS_BUCKET_NAME}/${PERSIST_SRC}" \
  "s3://${PREVIEW_AWS_BUCKET_NAME}/${PERSIST_DEST}" \
  --only-show-errors

echo "Persist sync complete."
