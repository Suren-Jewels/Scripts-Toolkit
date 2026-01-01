#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Filestore Utilization Summary
# Purpose   : Collect Filestore throughput, latency, and saturation indicators
#             across all projects and instances.
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
collect_filestore_metrics() {
  local project="$1"

  INSTANCES=$(gcloud filestore instances list \
    --project "$project" \
    --format="json(name,zone,tier,capacityGb)")

  METRICS=$(gcloud monitoring time-series list \
    --project "$project" \
    --filter='metric.type = starts_with("file.googleapis.com/instance")' \
    --interval="duration:${WINDOW}s" \
    --format="json" 2>/dev/null || echo "[]")

  jq -n \
    --arg project "$project" \
    --argjson instances "$INSTANCES" \
    --argjson metrics "$METRICS" \
    '
    $instances | map({
      project: $project,
      name: .name,
      zone: .zone,
      tier: .tier,
      capacity_gb: .capacityGb,
      throughput_read_avg: (
        $metrics[]
        | select(.metric.type | contains("read_bytes_count")))
        .points[].value.doubleValue
        | add / length
        // 0,
      throughput_write_avg: (
        $metrics[]
        | select(.metric.type | contains("write_bytes_count")))
        .points[].value.doubleValue
        | add / length
        // 0,
      latency_avg: (
        $metrics[]
        | select(.metric.type | contains("latency")))
        .points[].value.doubleValue
        | add / length
        // 0
    })
    '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_filestore_metrics "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  filestore_reports: .,
  instance_count: (map(.name) | length)
}
'
