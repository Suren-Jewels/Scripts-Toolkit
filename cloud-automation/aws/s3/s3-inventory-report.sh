#!/usr/bin/env bash
set -euo pipefail

# S3 inventory reporting:
# - List buckets
# - List objects in a bucket (optional)

usage() {
  echo "Usage: $0 [bucket_name]"
  echo "  bucket_name : Optional bucket to list objects"
  exit 1
}

BUCKET="${1:-}"

aws s3api list-buckets \
  --query "Buckets[].{Name:Name,Created:CreationDate}" \
  --output table

if [[ -n "${BUCKET}" ]]; then
  aws s3api list-objects \
    --bucket "${BUCKET}" \
    --query "Contents[].{Key:Key,Size:Size,LastModified:LastModified}" \
    --output table
fi
