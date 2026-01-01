#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS VPC Utilization Summary
# Purpose   : Collect ENI usage, subnet pressure, VPC traffic throughput,
#             packet drops, and saturation indicators across all regions.
# Output    : JSON (per‑VPC + region rollup)
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
WINDOW_SECONDS=3600

START_TIME=$(date -u -d "-${WINDOW_SECONDS} seconds" +%Y-%m-%dT%H:%M:%SZ)
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# ----------------------------- FUNCTIONS --------------------------------------
collect_vpc_metrics() {
  local region="$1"

  VPCS=$(aws ec2 describe-vpcs \
    --region "$region" \
    --query "Vpcs[].VpcId" \
    --output text)

  for vpc in $VPCS; do

    # ENI count
    ENI_COUNT=$(aws ec2 describe-network-interfaces \
      --region "$region" \
      --filters "Name=vpc-id,Values=$vpc" \
      --query "length(NetworkInterfaces)" \
      --output text)

    # Subnet IP pressure
    SUBNETS=$(aws ec2 describe-subnets \
      --region "$region" \
      --filters "Name=vpc-id,Values=$vpc" \
      --query "Subnets[].{id:SubnetId,available:AvailableIpAddressCount,total:CidrBlock}" \
      --output json)

    # CloudWatch VPC traffic metrics
    METRICS=$(aws cloudwatch get-metric-data \
      --region "$region" \
      --metric-data-queries "[
        {
          \"Id\": \"bytes_in\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/VPC\",
              \"MetricName\": \"BytesIn\",
              \"Dimensions\": [{\"Name\": \"VpcId\", \"Value\": \"${vpc}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"bytes_out\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/VPC\",
              \"MetricName\": \"BytesOut\",
              \"Dimensions\": [{\"Name\": \"VpcId\", \"Value\": \"${vpc}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"drops\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/VPC\",
              \"MetricName\": \"PacketDropCount\",
              \"Dimensions\": [{\"Name\": \"VpcId\", \"Value\": \"${vpc}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        }
      ]" \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
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
        throughput_in_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="bytes_in").Values
          | add
        ),
        throughput_out_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="bytes_out").Values
          | add
        ),
        packet_drops_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="drops").Values
          | add
        )
      }
      '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for r in $REGIONS; do
  DATA=$(collect_vpc_metrics "$r")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  vpc_reports: .,
  vpc_count: (map(.vpc) | length)
}
'
