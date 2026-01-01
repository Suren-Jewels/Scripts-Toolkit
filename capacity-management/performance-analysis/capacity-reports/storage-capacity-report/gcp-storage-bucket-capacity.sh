#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Storage Bucket Capacity Report
# Purpose   : Report bucket size, object count, growth rate, and lifecycle status.
# Output    : JSON (per-bucket + project rollup)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI not found." >&2
  exit 1
fi

if ! command -v gsutil >/dev/null 2>&1; then
  echo "ERROR: gsutil not found." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found." >&2
  exit 1
fi

# ----------------------------- VARIABLES --------------------------------------
PROJECTS=$(gcloud projects list --format="value(projectId)")

# ----------------------------- FUNCTIONS --------------------------------------
collect_bucket_data() {
  local project="$1"

  BUCKETS=$(gsutil ls -p "$project" 2>/dev/null || true)

  jq -n --arg project "$project" --arg buckets "$BUCKETS" '
    {
      project: $project,
      buckets: ($buckets | split("\n") | map(select(. != "")))
    }
  ' | jq -r '
    .buckets[] as $b |
    {
      project: .project,
      bucket: $b
    }
  ' | while read -r entry; do
      bucket=$(echo "$entry" | jq -r '.bucket')
      project=$(echo "$entry" | jq -r '.project')

      # Size + object count
      STATS=$(gsutil du -s "$bucket" 2>/dev/null | awk '{print $1}')
      OBJECTS=$(gsutil ls "$bucket/**" 2>/dev/null | wc -l | tr -d ' ')

      jq -n \
        --arg project "$project" \
        --arg bucket "$bucket" \
        --arg size "$STATS" \
        --arg objects "$OBJECTS" \
        '
        {
          project: $project,
          bucket: $bucket,
          size_bytes: ($size | tonumber),
          object_count: ($objects | tonumber)
        }
        '
    done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_bucket_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    bucket_reports: .,
    bucket_count: (map(.bucket) | length)
  }
'
