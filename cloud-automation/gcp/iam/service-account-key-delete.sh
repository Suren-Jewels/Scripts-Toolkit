#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a key for a Google Cloud service account.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_EMAIL:?SERVICE_ACCOUNT_EMAIL is required}"
KEY_ID="${KEY_ID:?KEY_ID is required}"

# Core logic
gcloud iam service-accounts keys delete "${KEY_ID}" \
  --iam-account="${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --quiet
