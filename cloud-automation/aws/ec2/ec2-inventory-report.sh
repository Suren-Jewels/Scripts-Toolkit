#!/usr/bin/env bash
set -euo pipefail

# EC2 inventory and reporting:
# - List instances
# - Show tags
# - Output summary

usage() {
  echo "Usage: $0 [region]"
  echo "  region : Optional AWS region (defaults to configured region)"
  exit 1
}

REGION="${1:-}"

if [[ -n "${REGION}" ]]; then
  REGION_FLAG="--region ${REGION}"
else
  REGION_FLAG=""
fi

aws ec2 describe-instances ${REGION_FLAG} \
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,AZ:Placement.AvailabilityZone,Tags:Tags}" \
  --output table
