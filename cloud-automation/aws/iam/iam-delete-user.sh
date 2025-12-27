#!/usr/bin/env bash
set -euo pipefail

# IAM user deletion:
# - Remove from groups
# - Delete access keys
# - Delete login profile
# - Delete user

usage() {
  echo "Usage: $0 <username>"
  echo "  username : IAM username to delete"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

USERNAME="$1"

GROUPS=$(aws iam list-groups-for-user \
  --user-name "${USERNAME}" \
  --query "Groups[].GroupName" \
  --output text)

for GROUP in ${GROUPS}; do
  aws iam remove-user-from-group \
    --user-name "${USERNAME}" \
    --group-name "${GROUP}"
done

ACCESS_KEYS=$(aws iam list-access-keys \
  --user-name "${USERNAME}" \
  --query "AccessKeyMetadata[].AccessKeyId" \
  --output text)

for KEY in ${ACCESS_KEYS}; do
  aws iam delete-access-key \
    --user-name "${USERNAME}" \
    --access-key-id "${KEY}"
done

aws iam delete-login-profile \
  --user-name "${USERNAME}" \
  >/dev/null 2>&1 || true

aws iam delete-user \
  --user-name "${USERNAME}"

echo "IAM user deleted: ${USERNAME}"
