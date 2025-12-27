#!/usr/bin/env bash
set -euo pipefail

# S3 bucket policy management:
# - Apply bucket policy JSON to bucket

usage() {
  echo "Usage: $0 <bucket_name> <policy_json_file>"
  echo "  bucket_name      : Name of the S3 bucket"
  echo "  policy_json_file : Path to bucket policy JSON"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

BUCKET_NAME="$1"
POLICY_FILE="$2"

aws s3api put-bucket-policy \
  --bucket "${BUCKET_NAME}" \
  --policy "file://${POLICY_FILE}"

echo "Bucket policy applied: ${BUCKET_NAME}"
