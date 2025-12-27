#!/usr/bin/env bash
set -euo pipefail

# IAM access key management:
# - Create access key
# - List access keys
# - Delete access key

usage() {
  echo "Usage:"
  echo "  $0 create <username>"
  echo "  $0 list <username>"
  echo "  $0 delete <username> <access_key_id>"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"
USERNAME="$2"

case "${ACTION}" in
  create)
    aws iam create-access-key \
      --user-name "${USERNAME}" \
      --query "{AccessKeyId:AccessKey.AccessKeyId,SecretAccessKey:AccessKey.SecretAccessKey}" \
      --output table
    ;;
  list)
    aws iam list-access-keys \
      --user-name "${USERNAME}" \
      --query "AccessKeyMetadata[].{AccessKeyId:AccessKeyId,Status:Status,Created:CreateDate}" \
      --output table
    ;;
  delete)
    if [[ $# -ne 3 ]]; then usage; fi
    ACCESS_KEY_ID="$3"
    aws iam delete-access-key \
      --user-name "${USERNAME}" \
      --access-key-id "${ACCESS_KEY_ID}"
    echo "Access key deleted: ${ACCESS_KEY_ID}"
    ;;
  *)
    usage
    ;;
esac
