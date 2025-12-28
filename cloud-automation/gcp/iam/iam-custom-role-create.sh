#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a custom IAM role in Google Cloud.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ROLE_ID="${ROLE_ID:?ROLE_ID is required}"
TITLE="${TITLE:?TITLE is required}"
DESCRIPTION="${DESCRIPTION:?DESCRIPTION is required}"
PERMISSIONS="${PERMISSIONS:?PERMISSIONS is required}"
# Format example: "storage.buckets.get,storage.objects.list"

# Core logic
gcloud iam roles create "${ROLE_ID}" \
  --project="${PROJECT_ID}" \
  --title="${TITLE}" \
  --description="${DESCRIPTION}" \
  --permissions="${PERMISSIONS}" \
  --stage="GA"
