#!/usr/bin/env bash
set -euo pipefail

# Capability: Update metadata or configuration for a Google Cloud Storage bucket.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
BUCKET_NAME="${BUCKET_NAME:?BUCKET_NAME is required}"
# Example: LABELS="env=prod,team=platform"
LABELS="${LABELS:?LABELS is required}"

# Core logic
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --update-labels="${LABELS}"
