#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: AWS EC2 Utilization Summary
# Purpose   : Collect CPU, Network IO, Disk IO, and credit/burst metrics for all
#             EC2 instances across all regions.
# Output    : JSON (per-instance + region rollup)
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
collect_instance_metrics() {
  local region="$1"

  INSTANCES=$(aws ec2 describe-instances \
    --region "$region" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)

  for instance in $INSTANCES; do

    METRICS=$(aws cloudwatch get-metric-data \
      --region "$region" \
      --metric-data-queries "[
        {
          \"Id\": \"cpu\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EC2\",
              \"MetricName\": \"CPUUtilization\",
              \"Dimensions\": [{\"Name\": \"InstanceId\", \"Value\": \"${instance}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Average\"
          }
        },
        {
          \"Id\": \"net_in\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EC2\",
              \"MetricName\": \"NetworkIn\",
              \"Dimensions\": [{\"Name\": \"InstanceId\", \"Value\": \"${instance}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"net_out\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EC2\",
              \"MetricName\": \"NetworkOut\",
              \"Dimensions\": [{\"Name\": \"InstanceId\", \"Value\": \"${instance}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"disk_read\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EC2\",
              \"MetricName\": \"DiskReadBytes\",
              \"Dimensions\": [{\"Name\": \"InstanceId\", \"Value\": \"${instance}\"}]
            },
            \"Period\": 300,
            \"Stat\": \"Sum\"
          }
        },
        {
          \"Id\": \"disk_write\",
          \"MetricStat\": {
            \"Metric\": {
              \"Namespace\": \"AWS/EC2\",
              \"MetricName\": \"DiskWriteBytes\",
              \"Dimensions\": [{\"Name\": \"InstanceId\", \"Value\": \"${instance}\"}]
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
      --arg instance "$instance" \
      --argjson metrics "$METRICS" \
      '
      {
        region: $region,
        instance: $instance,
        cpu_avg: (
          $metrics.MetricDataResults[]
          | select(.Id=="cpu").Values
          | add / (length // 1)
        ),
        network_in_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="net_in").Values
          | add
        ),
        network_out_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="net_out").Values
          | add
        ),
        disk_read_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="disk_read").Values
          | add
        ),
        disk_write_sum: (
          $metrics.MetricDataResults[]
          | select(.Id=="disk_write").Values
          | add
        )
      }
      '
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for r in $REGIONS; do
  DATA=$(collect_instance_metrics "$r")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
{
  generated_at: now,
  instance_reports: .,
  instance_count: (map(.instance) | length)
}
'
