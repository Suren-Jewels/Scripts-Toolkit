#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Network Throughput Summary
# Purpose   : Aggregate VPC flow logs to compute throughput, packet drops,
#             and network hotspots across all projects.
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
collect_network_data() {
  local project="$1"

  # List VPCs
  VPCS=$(gcloud compute networks list \
    --project "$project" \
    --format="value(name)")

  for vpc in $VPCS; do
    # Query flow logs via Cloud Logging
    LOGS=$(gcloud logging read \
      "resource.type=gce_subnetwork AND jsonPayload.connection.src_vpc='$vpc'" \
      --project="$project" \
      --format="json" \
      --freshness="${WINDOW}s" 2>/dev/null || echo "[]")

    echo "$LOGS" | jq -r --arg project "$project" --arg vpc "$vpc" '
      {
        project: $project,
        vpc: $vpc,
        samples: (.[].jsonPayload.connection // empty),
        throughput_bps: (
          [.[].jsonPayload.bytes_sent, .[].jsonPayload.bytes_received]
          | flatten
          | add
        ),
        packet_drops: (
          [.[].jsonPayload.packets_dropped]
          | flatten
          | add
        )
      }
    '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_network_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    vpc_reports: .,
    vpc_count: (. | length)
  }
'
