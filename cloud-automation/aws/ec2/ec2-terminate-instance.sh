#!/usr/bin/env bash
set -euo pipefail

# Terminate EC2 instance automation:
# - Instance shutdown
# - Resource cleanup
# - Tag-based or ID-based termination

usage() {
  echo "Usage: $0 <instance_id>"
  echo "  instance_id : EC2 instance ID to terminate"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

INSTANCE_ID="$1"

aws ec2 terminate-instances \
  --instance-ids "${INSTANCE_ID}" \
  --output text

echo "EC2 instance terminated: ${INSTANCE_ID}"
