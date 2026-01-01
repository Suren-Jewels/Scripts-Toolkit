#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS VPC Capacity Summary
# Purpose   : Report ENI usage, subnet saturation, bandwidth patterns, and
#             network-level capacity indicators across all regions.
# Output    : JSON (per-VPC + region rollup)
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
WINDOW="3600"  # 1 hour lookback

# ----------------------------- FUNCTIONS --------------------------------------
collect_region_data() {
  local region="$1"

  # List VPCs
  VPCS=$(aws ec2 describe-vpcs \
    --region "$region" \
    --query "Vpcs[].VpcId" \
    --output text)

  for vpc in $VPCS; do
    # ENI usage
    ENI_COUNT=$(aws ec2 describe-network-interfaces \
      --region "$region" \
      --filters "Name=vpc-id,Values=$vpc" \
      --query "length(NetworkInterfaces)" \
      --output text)

    # Subnet IP usage
    SUBNETS=$(aws ec2 describe-subnets \
      --region "$region" \
      --filters "Name=vpc-id,Values=$vpc" \
      --query "Subnets[].{id:SubnetId,available:AvailableIpAddressCount,total:CidrBlock}" \
      --output json)

    # CloudWatch metrics for VPC traffic
    METRICS=$(aws cloudwatch get-metric-data \
      --region "$region" \
      --metric-data-queries '[
        {
          "Id": "bytes_in",
          "MetricStat": {
            "Metric": {
              "Namespace": "AWS/VPC",
              "MetricName": "BytesIn",
              "Dimensions": [{"Name": "VpcId", "Value": "'"$vpc"'"}]
            },
            "Period": 300,
            "Stat": "Sum"
          }
        },
        {
          "Id": "bytes_out",
          "MetricStat": {
            "Metric": {
              "Namespace": "AWS/VPC",
              "MetricName": "BytesOut",
              "Dimensions": [{"Name": "VpcId", "Value": "'"$vpc"'"}]
            },
            "Period": 300,
            "Stat": "Sum"
          }
        }
      ]' \
      --start-time "$(date -u -d "-${WINDOW} seconds" +%Y-%m-%dT%H:%M:%SZ)" \
      --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --output json 2>/dev/null || echo "{}")

    jq -n \
      --arg region "$region" \
      --arg vpc "$vpc" \
      --arg eni "$ENI_COUNT" \
      --argjson subnets "$SUBNETS" \
      --argjson metrics "$METRICS" \
      '
      {
        region: $region,
        vpc: $vpc,
        eni_count: ($eni | tonumber),
        subnets: $subnets,
        traffic_metrics: $metrics
      }
      '
  done
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
    vpc_reports: .,
    vpc_count: (. | length)
  }
'
