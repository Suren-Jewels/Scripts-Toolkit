#!/usr/bin/env bash
set -euo pipefail

# S3 bucket deletion:
# - Empty bucket
# - Delete bucket

usage() {
  echo "Usage: $0 <bucket_name>"
  echo "  bucket_name : Name of the S3 bucket"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

BUCKET_NAME="$1"

aws s3 rm "s3://${BUCKET_NAME}" --recursive

aws s3api delete-bucket \
  --bucket "${BUCKET_NAME}"

echo "S3 bucket deleted: ${BUCKET_NAME}"
