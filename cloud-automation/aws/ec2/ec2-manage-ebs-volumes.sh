#!/usr/bin/env bash
set -euo pipefail

# EBS volume automation:
# - Attach
# - Detach
# - Resize

usage() {
  echo "Usage:"
  echo "  $0 attach <volume_id> <instance_id> <device>"
  echo "  $0 detach <volume_id>"
  echo "  $0 resize <volume_id> <new_size_gb>"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"

case "${ACTION}" in
  attach)
    if [[ $# -ne 4 ]]; then usage; fi
    VOLUME_ID="$2"
    INSTANCE_ID="$3"
    DEVICE="$4"
    aws ec2 attach-volume \
      --volume-id "${VOLUME_ID}" \
      --instance-id "${INSTANCE_ID}" \
      --device "${DEVICE}"
    echo "EBS volume attached: ${VOLUME_ID} -> ${INSTANCE_ID}"
    ;;
  detach)
    if [[ $# -ne 2 ]]; then usage; fi
    VOLUME_ID="$2"
    aws ec2 detach-volume \
      --volume-id "${VOLUME_ID}"
    echo "EBS volume detached: ${VOLUME_ID}"
    ;;
  resize)
    if [[ $# -ne 3 ]]; then usage; fi
    VOLUME_ID="$2"
    NEW_SIZE="$3"
    aws ec2 modify-volume \
      --volume-id "${VOLUME_ID}" \
      --size "${NEW_SIZE}"
    echo "EBS volume resized: ${VOLUME_ID} -> ${NEW_SIZE}GB"
    ;;
  *)
    usage
    ;;
esac
