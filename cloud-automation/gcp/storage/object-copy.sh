#!/usr/bin/env bash
set -euo pipefail

# Capability: Copy an object between Google Cloud Storage buckets or within the same bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SOURCE_BUCKET="${SOURCE_BUCKET:?SOURCE_BUCKET is required}"
SOURCE_OBJECT="${SOURCE_OBJECT:?SOURCE_OBJECT is required}"
DEST_BUCKET="${DEST_BUCKET:?DEST_BUCKET is required}"
DEST_OBJECT="${DEST_OBJECT:?DEST_OBJECT is required}"

# Core logic
gcloud storage cp \
  "gs://${SOURCE_BUCKET}/${SOURCE_OBJECT}" \
  "gs://${DEST_BUCKET}/${DEST_OBJECT}" \
  --project="${PROJECT_ID}"
