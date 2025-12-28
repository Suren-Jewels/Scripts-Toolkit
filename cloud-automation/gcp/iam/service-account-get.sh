#!/usr/bin/env bash
set -euo pipefail

# Capability: Get details for a specific Google Cloud service account.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_EMAIL:?SERVICE_ACCOUNT_EMAIL is required}"

# Core logic
gcloud iam service-accounts describe "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}"
