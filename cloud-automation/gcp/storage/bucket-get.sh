#!/usr/bin/env bash
set -euo pipefail

# Capability: Get metadata for a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"

# Core logic
gcloud storage buckets describe "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --format=json
