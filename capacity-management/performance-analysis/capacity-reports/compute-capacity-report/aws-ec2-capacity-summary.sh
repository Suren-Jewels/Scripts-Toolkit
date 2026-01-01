#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS EC2 Capacity Summary
# Purpose   : Report EC2 fleet utilization, instance families, and scaling headroom.
# Output    : JSON (per-region + global rollup)
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
REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# ----------------------------- FUNCTIONS --------------------------------------
collect_region_data() {
  local region="$1"

  INSTANCES=$(aws ec2 describe-instances \
    --region "$region" \
    --query "Reservations[].Instances[].{id:InstanceId,type:InstanceType,state:State.Name,az:Placement.AvailabilityZone}" \
    --output json)

  QUOTAS=$(aws service-quotas list-service-quotas \
    --service-code ec2 \
    --region "$region" \
    --output json)

  jq -n \
    --arg region "$region" \
    --argjson instances "$INSTANCES" \
    --argjson quotas "$QUOTAS" \
    '
    {
      region: $region,
      instance_inventory: $instances,
      quota_summary: $quotas
    }
    '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for r in $REGIONS; do
  DATA=$(collect_region_data "$r")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    region_reports: .,
    region_count: (. | length)
  }
'
