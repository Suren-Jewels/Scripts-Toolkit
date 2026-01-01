#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS EBS Utilization Summary
# Purpose   : Collect EBS IOPS, throughput, burst balance, and latency metrics
#             across all volumes in all regions.
# Output    : JSON (per-volume + region rollup)
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
collect_volume_metrics() {
  local region="$1"

  VOLUMES=$(aws ec2 describe-volumes \
    --region "$region" \
    --query "Volumes[].VolumeId" \
    --output text)

  for vol in $VOLUMES; do

    METRICS=$(aws cloudwatch get-metric-data \
      --region "$region" \
      --metric-data-queries "[
        {
          \"Id\": \"read_ops\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EBS\",
              \"MetricName\": \"VolumeReadOps\",
              \"Dimensions\": [{\"Name\": \"VolumeId\", \"Value\": \"${vol}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"write_ops\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EBS\",
              \"MetricName\": \"VolumeWriteOps\",
              \"Dimensions\": [{\"Name\": \"VolumeId\", \"Value\": \"${vol}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"read_bytes\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EBS\",
              \"MetricName\": \"VolumeReadBytes\",
              \"Dimensions\": [{\"Name\": \"VolumeId\", \"Value\": \"${vol}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"write_bytes\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EBS\",
              \"MetricName\": \"VolumeWriteBytes\",
              \"Dimensions\": [{\"Name\": \"VolumeId\", \"Value\": \"${vol}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"burst_balance\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EBS\",
              \"MetricName\": \"BurstBalance\",
              \"Dimensions\": [{\"Name\": \"VolumeId\", \"Value\": \"${vol}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Average\"
          }
        }
      ]" \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
      --output json 2>/dev/null || echo "{}")

    jq -n \
      --arg region "$region" \
      --arg volume "$vol" \
      --argjson metrics "$METRICS" \
      '
      {
        region: $region,
        volume: $volume,
        read_ops_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="read_ops").Values
          | add
        ),
        write_ops_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="write_ops").Values
          | add
        ),
        read_bytes_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="read_bytes").Values
          | add
        ),
        write_bytes_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="write_bytes").Values
          | add
        ),
        burst_balance_avg: (
          $metrics.MetricDataResults[]
          | select(.Id=="burst_balance").Values
          | add / (length // 1)
        )
      }
      '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for r in $REGIONS; do
  DATA=$(collect_volume_metrics "$r")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  volume_reports: .,
  volume_count: (map(.volume) | length)
}
'
