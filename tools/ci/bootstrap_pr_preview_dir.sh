#!/usr/bin/env bash
# If s3://$PREVIEW_AWS_BUCKET_NAME/pr$PR_NUMBER/ is empty, copy from prod-copy/ so
# hugo deploy can do an incremental update. Requires AWS CLI credentials in env.
set -euo pipefail

: "${PR_NUMBER:?PR_NUMBER must be set}"
: "${PREVIEW_AWS_BUCKET_NAME:?PREVIEW_AWS_BUCKET_NAME must be set}"

PR_PREFIX="pr${PR_NUMBER}/"

KEY_COUNT="$(aws s3api list-objects-v2 \
  --bucket "$PREVIEW_AWS_BUCKET_NAME" \
  --prefix "$PR_PREFIX" \
  --max-keys 1 \
  --query 'KeyCount' \
  --output text)"

if [ "${KEY_COUNT:-0}" != "0" ] && [ -n "${KEY_COUNT}" ] && [ "${KEY_COUNT}" != "None" ]; then
  echo "Prefix s3://${PREVIEW_AWS_BUCKET_NAME}/${PR_PREFIX} already has objects; skipping prod-copy bootstrap."
  exit 0
fi

echo "Prefix s3://${PREVIEW_AWS_BUCKET_NAME}/${PR_PREFIX} is empty; bootstrapping from prod-copy/."

PC_COUNT="$(aws s3api list-objects-v2 \
  --bucket "$PREVIEW_AWS_BUCKET_NAME" \
  --prefix "prod-copy/" \
  --max-keys 1 \
  --query 'KeyCount' \
  --output text)"

if [ "${PC_COUNT:-0}" = "0" ] || [ -z "${PC_COUNT}" ] || [ "${PC_COUNT}" = "None" ]; then
  echo "prod-copy/ is empty or missing; cannot bootstrap PR preview. Run the cron production deploy to populate prod-copy/ first."
  exit 1
fi

aws s3 sync \
  "s3://${PREVIEW_AWS_BUCKET_NAME}/prod-copy/" \
  "s3://${PREVIEW_AWS_BUCKET_NAME}/${PR_PREFIX}" \
  --only-show-errors

echo "Bootstrap sync from prod-copy/ complete."
