#!/usr/bin/env bash
set -euo pipefail

# Capability: Apply a lifecycle management policy to a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
LIFECYCLE_FILE="${LIFECYCLE_FILE:?LIFECYCLE_FILE is required}"
# Example: lifecycle.json

# Core logic
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --lifecycle-file="${LIFECYCLE_FILE}"
