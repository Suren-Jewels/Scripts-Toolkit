#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Idle Compute Resource Detection
# Purpose   : Identify VMs with low CPU, low network, and low disk activity
#             over a defined lookback window.
# Output    : JSON (per-instance idle classification)
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
WINDOW="86400"  # 24 hours

CPU_THRESHOLD="0.05"       # 5%
NET_THRESHOLD="10000"      # 10 KB/s
DISK_THRESHOLD="50000"     # 50 KB/s

# ----------------------------- FUNCTIONS --------------------------------------
collect_idle_data() {
  local project="$1"

  gcloud monitoring time-series list \
    --project "$project" \
    --filter='metric.type = starts_with("compute.googleapis.com/instance")' \
    --format="json" \
    --interval="duration:${WINDOW}s" | jq -r \
    --arg project "$project" \
    --arg cpu_t "$CPU_THRESHOLD" \
    --arg net_t "$NET_THRESHOLD" \
    --arg disk_t "$DISK_THRESHOLD" '
    {
      project: $project,
      idle_instances: [
        .[] |
        {
          metric: .metric.type,
          instance: .resource.labels.instance_id,
          zone: .resource.labels.zone,
          avg_value: ( .points | map(.value.doubleValue) | add / length )
        }
      ]
      | group_by(.instance)
      | map({
          instance: .[0].instance,
          zone: .[0].zone,
          cpu_idle: (
            (map(select(.metric | contains("cpu/utilization")))[0].avg_value // 1)
            < ($cpu_t | tonumber)
          ),
          net_idle: (
            (map(select(.metric | contains("network/sent_bytes_count")))[0].avg_value // 1)
            < ($net_t | tonumber)
          ),
          disk_idle: (
            (map(select(.metric | contains("disk/read_bytes_count")))[0].avg_value // 1)
            < ($disk_t | tonumber)
          )
        })
      | map(select(.cpu_idle and .net_idle and .disk_idle))
    }
  '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_idle_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    project_reports: .,
    project_count: (. | length)
  }
'
