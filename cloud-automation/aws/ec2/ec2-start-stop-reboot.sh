#!/usr/bin/env bash
set -euo pipefail

# EC2 lifecycle operations:
# - Start
# - Stop
# - Reboot

usage() {
  echo "Usage: $0 <start|stop|reboot> <instance_id>"
  echo "  action       : start | stop | reboot"
  echo "  instance_id  : EC2 instance ID"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

ACTION="$1"
INSTANCE_ID="$2"

case "${ACTION}" in
  start)
    aws ec2 start-instances --instance-ids "${INSTANCE_ID}" --output text
    echo "EC2 instance started: ${INSTANCE_ID}"
    ;;
  stop)
    aws ec2 stop-instances --instance-ids "${INSTANCE_ID}" --output text
    echo "EC2 instance stopped: ${INSTANCE_ID}"
    ;;
  reboot)
    aws ec2 reboot-instances --instance-ids "${INSTANCE_ID}" --output text
    echo "EC2 instance rebooted: ${INSTANCE_ID}"
    ;;
  *)
    usage
    ;;
esac
