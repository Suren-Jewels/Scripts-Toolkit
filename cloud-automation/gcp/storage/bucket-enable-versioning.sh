#!/usr/bin/env bash
set -euo pipefail

# Capability: Enable object versioning on a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"

# Core logic
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --versioning
