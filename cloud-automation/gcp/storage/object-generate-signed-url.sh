#!/usr/bin/env bash
set -euo pipefail

# Capability: Generate a signed URL for a Google Cloud Storage object.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
OBJECT_NAME="${OBJECT_NAME:?OBJECT_NAME is required}"
EXPIRATION="${EXPIRATION:?EXPIRATION is required}"
# Example: EXPIRATION="3600" (seconds)

# Core logic
gcloud storage sign-url \
  "gs://${BUCKET_NAME}/${OBJECT_NAME}" \
  --project="${PROJECT_ID}" \
  --expires-in="${EXPIRATION}"
