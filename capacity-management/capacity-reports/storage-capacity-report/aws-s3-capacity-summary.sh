#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS S3 Capacity Summary
# Purpose   : Report S3 bucket size, storage class distribution, and lifecycle
#             optimization opportunities across all regions.
# Output    : JSON (per-bucket + global rollup)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI not found." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found." >&2
  exit 1
fi

# ----------------------------- VARIABLES --------------------------------------
BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# ----------------------------- FUNCTIONS --------------------------------------
collect_bucket_data() {
  local bucket="$1"

  # Region
  REGION=$(aws s3api get-bucket-location \
    --bucket "$bucket" \
    --query "LocationConstraint" \
    --output text)

  if [[ "$REGION" == "None" ]]; then
    REGION="us-east-1"
  fi

  # Size + object count
  SIZE=$(aws s3api list-objects \
    --bucket "$bucket" \
    --query "sum(Contents[].Size)" \
    --output text 2>/dev/null || echo 0)

  OBJECTS=$(aws s3api list-objects \
    --bucket "$bucket" \
    --query "length(Contents[])" \
    --output text 2>/dev/null || echo 0)

  # Storage class breakdown
  STORAGE_CLASSES=$(aws s3api list-objects \
    --bucket "$bucket" \
    --query "Contents[].StorageClass" \
    --output json 2>/dev/null | jq -r '
      group_by(.) | map({class: .[0], count: length})
    ')

  jq -n \
    --arg bucket "$bucket" \
    --arg region "$REGION" \
    --arg size "$SIZE" \
    --arg objects "$OBJECTS" \
    --argjson classes "$STORAGE_CLASSES" \
    '
    {
      bucket: $bucket,
      region: $region,
      size_bytes: ($size | tonumber),
      object_count: ($objects | tonumber),
      storage_classes: $classes
    }
    '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for b in $BUCKETS; do
  DATA=$(collect_bucket_data "$b")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    bucket_reports: .,
    bucket_count: (. | length)
  }
'
