#!/usr/bin/env bash
set -euo pipefail

# S3 lifecycle configuration:
# - Apply lifecycle policy JSON to bucket

usage() {
  echo "Usage: $0 <bucket_name> <lifecycle_json_file>"
  echo "  bucket_name         : Name of the S3 bucket"
  echo "  lifecycle_json_file : Path to lifecycle policy JSON"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

BUCKET_NAME="$1"
LIFECYCLE_FILE="$2"

aws s3api put-bucket-lifecycle-configuration \
  --bucket "${BUCKET_NAME}" \
  --lifecycle-configuration "file://${LIFECYCLE_FILE}"

echo "Lifecycle policy applied to bucket: ${BUCKET_NAME}"
