#!/usr/bin/env bash
set -euo pipefail

# S3 bucket creation:
# - Create bucket
# - Optional region
# - Optional tags

usage() {
  echo "Usage: $0 <bucket_name> [region]"
  echo "  bucket_name : Name of the S3 bucket"
  echo "  region      : Optional AWS region"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

BUCKET_NAME="$1"
REGION="${2:-}"

if [[ -n "${REGION}" ]]; then
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"
else
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}"
fi

echo "S3 bucket created: ${BUCKET_NAME}"
