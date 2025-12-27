#!/usr/bin/env bash
set -euo pipefail

# IAM role creation:
# - Create role
# - Attach trust policy
# - Optional tags

usage() {
  echo "Usage: $0 <role_name> <trust_policy_json_file>"
  echo "  role_name             : IAM role name"
  echo "  trust_policy_json_file: Path to trust policy JSON"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

ROLE_NAME="$1"
TRUST_POLICY_FILE="$2"

aws iam create-role \
  --role-name "${ROLE_NAME}" \
  --assume-role-policy-document "file://${TRUST_POLICY_FILE}" \
  --tags "Key=Name,Value=${ROLE_NAME}" \
  >/dev/null

echo "IAM role created: ${ROLE_NAME}"
