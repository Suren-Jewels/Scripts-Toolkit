#!/usr/bin/env bash
set -euo pipefail

# Capability: List objects in a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"

# Core logic
gcloud storage ls \
  "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --recursive \
  --format=json
