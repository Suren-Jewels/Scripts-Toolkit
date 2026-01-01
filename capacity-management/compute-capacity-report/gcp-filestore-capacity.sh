#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Filestore Capacity Report
# Purpose   : Summarize Filestore usage, capacity, throughput saturation,
#             and quota limits across all projects.
# Output    : JSON (per-instance + project rollup)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI not found." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found." >&2
  exit 1
fi

# ----------------------------- VARIABLES --------------------------------------
PROJECTS=$(gcloud projects list --format="value(projectId)")
WINDOW="3600"  # 1 hour lookback

# ----------------------------- FUNCTIONS --------------------------------------
collect_filestore_data() {
  local project="$1"

  # List Filestore instances
  INSTANCES=$(gcloud filestore instances list \
    --project "$project" \
    --format="json(name,zone,tier,capacityGb,fileShares)")

  # Collect metrics from Cloud Monitoring
  METRICS=$(gcloud monitoring time-series list \
    --project "$project" \
    --filter='metric.type = starts_with("file.googleapis.com/instance")' \
    --interval="duration:${WINDOW}s" \
    --format="json")

  jq -n \
    --arg project "$project" \
    --argjson instances "$INSTANCES" \
    --argjson metrics "$METRICS" '
    {
      project: $project,
      filestore_instances: (
        $instances | map({
          name: .name,
          zone: .zone,
          tier: .tier,
          capacity_gb: .capacityGb,
          shares: .fileShares
        })
      ),
      metric_samples: $metrics
    }
    '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_filestore_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    filestore_reports: .,
    project_count: (. | length)
  }
'
