#!/usr/bin/env bash
set -euo pipefail

# Capability: Remove an IAM policy binding from a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
ROLE="${ROLE:?ROLE is required}"
MEMBER="${MEMBER:?MEMBER is required}"

# Core logic
gcloud storage buckets remove-iam-policy-binding "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --role="${ROLE}" \
  --member="${MEMBER}"
