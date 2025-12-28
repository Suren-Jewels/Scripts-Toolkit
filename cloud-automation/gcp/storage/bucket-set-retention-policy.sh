#!/usr/bin/env bash
set -euo pipefail

# Capability: Apply a retention policy to a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
RETENTION_PERIOD="${RETENTION_PERIOD:?RETENTION_PERIOD is required}"
# Example: RETENTION_PERIOD="3600s" or "86400s"

# Core logic
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --retention-period="${RETENTION_PERIOD}"
