#!/usr/bin/env bash
set -euo pipefail

# Capability: Update a custom IAM role in a Google Cloud project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ROLE_ID="${ROLE_ID:?ROLE_ID is required}"
PERMISSIONS="${PERMISSIONS:?PERMISSIONS is required}"
# Format example: "storage.buckets.get,storage.objects.list"

# Core logic
gcloud iam roles update "${ROLE_ID}" \
  --project="${PROJECT_ID}" \
  --permissions="${PERMISSIONS}" \
  --stage="GA"
