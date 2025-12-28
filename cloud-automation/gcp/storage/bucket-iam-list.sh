#!/usr/bin/env bash
set -euo pipefail

# Capability: List IAM policy bindings for a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"

# Core logic
gcloud storage buckets get-iam-policy "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --format=json
