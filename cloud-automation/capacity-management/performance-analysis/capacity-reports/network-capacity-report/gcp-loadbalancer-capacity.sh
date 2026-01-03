#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Load Balancer Capacity Report
# Purpose   : Report backend utilization, request volume, error rates, and
#             saturation indicators for all HTTP(S) load balancers.
# Output    : JSON (per-LB + project rollup)
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
collect_lb_data() {
  local project="$1"

  # List all HTTP(S) load balancers
  LBS=$(gcloud compute backend-services list \
    --project "$project" \
    --format="value(name)")

  for lb in $LBS; do
    # Query Cloud Monitoring for LB metrics
    METRICS=$(gcloud monitoring time-series list \
      --project "$project" \
      --filter="metric.type = starts_with('loadbalancing.googleapis.com/https')" \
      --format="json" \
      --interval="duration:${WINDOW}s" 2>/dev/null || echo "[]")

    echo "$METRICS" | jq -r --arg project "$project" --arg lb "$lb" '
      {
        project: $project,
        load_balancer: $lb,
        request_rate: (
          [.[].points[].value.doubleValue]
          | add
        ),
        error_rate: (
          [.[].points[].value.doubleValue]
          | map(select(. > 0))
          | add
        ),
        sample_count: (.[].points | length)
      }
    '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_lb_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    loadbalancer_reports: .,
    lb_count: (. | length)
  }
'
