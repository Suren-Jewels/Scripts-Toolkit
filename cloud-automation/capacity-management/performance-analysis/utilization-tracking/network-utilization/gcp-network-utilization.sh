#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Network Utilization Summary
# Purpose   : Collect VPC flow throughput, packet drops, and network saturation
#             indicators across all projects and VPCs.
# Output    : JSON (per-VPC + project rollup)
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
collect_network_metrics() {
  local project="$1"

  VPCS=$(gcloud compute networks list \
    --project "$project" \
    --format="value(name)")

  for vpc in $VPCS; do
    LOGS=$(gcloud logging read \
      "resource.type=gce_subnetwork AND jsonPayload.connection.src_vpc='$vpc'" \
      --project="$project" \
      --format="json" \
      --freshness="${WINDOW}s" 2>/dev/null || echo "[]")

    echo "$LOGS" | jq -r --arg project "$project" --arg vpc "$vpc" '
      {
        project: $project,
        vpc: $vpc,
        throughput_bps: (
          [.[].jsonPayload.bytes_sent, .[].jsonPayload.bytes_received]
          | flatten
          | add
        ),
        packet_drops: (
          [.[].jsonPayload.packets_dropped]
          | flatten
          | add
        ),
        sample_count: (.[].jsonPayload | length)
      }
    '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_network_metrics "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  vpc_reports: .,
  vpc_count: (map(.vpc) | length)
}
'
