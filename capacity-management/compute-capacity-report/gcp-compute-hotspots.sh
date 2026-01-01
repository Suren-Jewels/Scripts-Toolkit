#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Compute Hotspot Detection
# Purpose   : Identify VMs with sustained CPU, RAM, or disk IO pressure.
# Output    : JSON (per-instance hotspot report)
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
collect_hotspots() {
  local project="$1"

  # CPU, RAM, Disk IO metrics via Cloud Monitoring
  gcloud monitoring time-series list \
    --project "$project" \
    --filter='metric.type = starts_with("compute.googleapis.com/instance")' \
    --format="json" \
    --interval="duration:${WINDOW}s" | jq -r --arg project "$project" '
      {
        project: $project,
        hotspots: [
          .[] |
          {
            metric: .metric.type,
            instance: .resource.labels.instance_id,
            zone: .resource.labels.zone,
            avg_value: ( .points | map(.value.doubleValue) | add / length ),
            threshold_exceeded: (
              if (.metric.type | contains("cpu/utilization")) and
                 ((.points | map(.value.doubleValue) | add / length) > 0.75)
              then true
              elif (.metric.type | contains("memory/usage")) and
                   ((.points | map(.value.doubleValue) | add / length) > 0.80)
              then true
              elif (.metric.type | contains("disk/read_bytes_count")) and
                   ((.points | map(.value.doubleValue) | add / length) > 50000000)
              then true
              else false
              end
            )
          }
        ]
      }
    '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_hotspots "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    project_reports: .,
    project_count: (. | length)
  }
'
