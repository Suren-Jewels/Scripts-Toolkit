#!/usr/bin/env bash
set -euo pipefail

# IAM policy management:
# - Attach policy to user or role
# - Detach policy from user or role

usage() {
  echo "Usage:"
  echo "  $0 attach user|role <name> <policy_arn>"
  echo "  $0 detach user|role <name> <policy_arn>"
  exit 1
}

if [[ $# -ne 4 ]]; then
  usage
fi

ACTION="$1"
TARGET_TYPE="$2"
TARGET_NAME="$3"
POLICY_ARN="$4"

case "${TARGET_TYPE}" in
  user)
    ATTACH_CMD="aws iam attach-user-policy --user-name ${TARGET_NAME} --policy-arn ${POLICY_ARN}"
    DETACH_CMD="aws iam detach-user-policy --user-name ${TARGET_NAME} --policy-arn ${POLICY_ARN}"
    ;;
  role)
    ATTACH_CMD="aws iam attach-role-policy --role-name ${TARGET_NAME} --policy-arn ${POLICY_ARN}"
    DETACH_CMD="aws iam detach-role-policy --role-name ${TARGET_NAME} --policy-arn ${POLICY_ARN}"
    ;;
  *)
    usage
    ;;
esac

case "${ACTION}" in
  attach)
    eval "${ATTACH_CMD}"
    echo "Policy attached: ${POLICY_ARN} -> ${TARGET_TYPE} ${TARGET_NAME}"
    ;;
  detach)
    eval "${DETACH_CMD}"
    echo "Policy detached: ${POLICY_ARN} -> ${TARGET_TYPE} ${TARGET_NAME}"
    ;;
  *)
    usage
    ;;
esac
