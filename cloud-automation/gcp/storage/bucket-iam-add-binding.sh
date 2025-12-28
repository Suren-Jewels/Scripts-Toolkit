#!/usr/bin/env bash
set -euo pipefail

# Capability: Add an IAM policy binding to a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
ROLE="${ROLE:?ROLE is required}"
MEMBER="${MEMBER:?MEMBER is required}"

# Core logic
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --role="${ROLE}" \
  --member="${MEMBER}"
