#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Compute Utilization Summary
# Purpose   : Collect CPU, RAM, Disk IO, and Network IO utilization for all
#             Compute Engine instances across all projects.
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
collect_instance_metrics() {
  local project="$1"

  # CPU, RAM, Disk, Network metrics from Cloud Monitoring
  METRICS=$(gcloud monitoring time-series list \
    --project "$project" \
    --filter='metric.type = starts_with("compute.googleapis.com/instance")' \
    --interval="duration:${WINDOW}s" \
    --format="json" 2>/dev/null || echo "[]")

  echo "$METRICS" | jq -r --arg project "$project" '
    group_by(.resource.labels.instance_id) |
    map({
      project: $project,
      instance: .[0].resource.labels.instance_id,
      zone: .[0].resource.labels.zone,
      cpu_avg: (
        map(select(.metric.type | contains("cpu/utilization")))
        | map(.points[].value.doubleValue)
        | add / length
      ),
      ram_avg: (
        map(select(.metric.type | contains("memory/usage")))
        | map(.points[].value.doubleValue)
        | add / length
      ),
      disk_read_avg: (
        map(select(.metric.type | contains("disk/read_bytes_count")))
        | map(.points[].value.doubleValue)
        | add / length
      ),
      disk_write_avg: (
        map(select(.metric.type | contains("disk/write_bytes_count")))
        | map(.points[].value.doubleValue)
        | add / length
      ),
      net_rx_avg: (
        map(select(.metric.type | contains("network/received_bytes_count")))
        | map(.points[].value.doubleValue)
        | add / length
      ),
      net_tx_avg: (
        map(select(.metric.type | contains("network/sent_bytes_count")))
        | map(.points[].value.doubleValue)
        | add / length
      )
    })
  '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_instance_metrics "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  instance_reports: .,
  instance_count: (map(.instance) | length)
}
'
