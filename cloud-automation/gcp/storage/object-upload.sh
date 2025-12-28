#!/usr/bin/env bash
set -euo pipefail

# Capability: Upload an object to a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
SOURCE_FILE="${SOURCE_FILE:?SOURCE_FILE is required}"
DESTINATION_OBJECT="${DESTINATION_OBJECT:?DESTINATION_OBJECT is required}"

# Core logic
gcloud storage cp "${SOURCE_FILE}" \
  "gs://${BUCKET_NAME}/${DESTINATION_OBJECT}" \
  --project="${PROJECT_ID}"
