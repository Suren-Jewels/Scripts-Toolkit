#!/usr/bin/env bash
set -euo pipefail

# S3 sync operations:
# - Sync local directory to bucket
# - Sync bucket to local directory

usage() {
  echo "Usage:"
  echo "  $0 to-s3 <local_dir> <bucket_name> [prefix]"
  echo "  $0 from-s3 <bucket_name> <prefix> <local_dir>"
  exit 1
}

if [[ $# -lt 3 ]]; then
  usage
fi

ACTION="$1"

case "${ACTION}" in
  to-s3)
    LOCAL_DIR="$2"
    BUCKET="$3"
    PREFIX="${4:-}"
    aws s3 sync "${LOCAL_DIR}" "s3://${BUCKET}/${PREFIX}"
    echo "Synced local -> s3://${BUCKET}/${PREFIX}"
    ;;
  from-s3)
    BUCKET="$2"
    PREFIX="$3"
    LOCAL_DIR="$4"
    aws s3 sync "s3://${BUCKET}/${PREFIX}" "${LOCAL_DIR}"
    echo "Synced s3://${BUCKET}/${PREFIX} -> local"
    ;;
  *)
    usage
    ;;
esac
