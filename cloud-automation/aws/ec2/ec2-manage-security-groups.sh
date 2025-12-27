#!/usr/bin/env bash
set -euo pipefail

# EC2 security group automation:
# - Add inbound rule
# - Remove inbound rule
# - List rules

usage() {
  echo "Usage: $0 <add|remove|list> <security_group_id> [protocol] [port] [cidr]"
  echo "  add/remove : Requires protocol, port, cidr"
  echo "  list       : Only security_group_id"
  exit 1
}

ACTION="$1"
SG_ID="$2"

case "${ACTION}" in
  add)
    if [[ $# -ne 5 ]]; then usage; fi
    PROTOCOL="$3"
    PORT="$4"
    CIDR="$5"
    aws ec2 authorize-security-group-ingress \
      --group-id "${SG_ID}" \
      --protocol "${PROTOCOL}" \
      --port "${PORT}" \
      --cidr "${CIDR}"
    echo "Rule added to security group: ${SG_ID}"
    ;;
  remove)
    if [[ $# -ne 5 ]]; then usage; fi
    PROTOCOL="$3"
    PORT="$4"
    CIDR="$5"
    aws ec2 revoke-security-group-ingress \
      --group-id "${SG_ID}" \
      --protocol "${PROTOCOL}" \
      --port "${PORT}" \
      --cidr "${CIDR}"
    echo "Rule removed from security group: ${SG_ID}"
    ;;
  list)
    if [[ $# -ne 2 ]]; then usage; fi
    aws ec2 describe-security-groups \
      --group-ids "${SG_ID}" \
      --query "SecurityGroups[0].IpPermissions"
    ;;
  *)
    usage
    ;;
esac
