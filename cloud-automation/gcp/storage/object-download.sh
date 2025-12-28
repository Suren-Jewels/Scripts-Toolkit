#!/usr/bin/env bash
set -euo pipefail

# Capability: Download an object from a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
OBJECT_NAME="${OBJECT_NAME:?OBJECT_NAME is required}"
DESTINATION_FILE="${DESTINATION_FILE:?DESTINATION_FILE is required}"

# Core logic
gcloud storage cp \
  "gs://${BUCKET_NAME}/${OBJECT_NAME}" \
  "${DESTINATION_FILE}" \
  --project="${PROJECT_ID}"
