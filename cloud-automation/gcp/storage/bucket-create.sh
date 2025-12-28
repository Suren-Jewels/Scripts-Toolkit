#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${LOCATION}"
