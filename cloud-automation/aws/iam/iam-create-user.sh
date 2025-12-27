#!/usr/bin/env bash
set -euo pipefail

# IAM user creation:
# - Create user
# - Add to groups
# - Tag user

usage() {
  echo "Usage: $0 <username> [group1,group2,...]"
  echo "  username : IAM username"
  echo "  groups   : Optional comma-separated list of IAM groups"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

USERNAME="$1"
GROUPS="${2:-}"

aws iam create-user \
  --user-name "${USERNAME}" \
  --tags "Key=Name,Value=${USERNAME}" \
  >/dev/null

if [[ -n "${GROUPS}" ]]; then
  IFS=',' read -ra GROUP_LIST <<< "${GROUPS}"
  for GROUP in "${GROUP_LIST[@]}"; do
    aws iam add-user-to-group \
      --user-name "${USERNAME}" \
      --group-name "${GROUP}"
  done
fi

echo "IAM user created: ${USERNAME}"
