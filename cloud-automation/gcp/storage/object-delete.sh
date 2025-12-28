#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an object from a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
OBJECT_NAME="${OBJECT_NAME:?OBJECT_NAME is required}"

# Core logic
gcloud storage rm \
  "gs://${BUCKET_NAME}/${OBJECT_NAME}" \
  --project="${PROJECT_ID}"
