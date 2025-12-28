#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a Google Cloud service account.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:?SERVICE_ACCOUNT_NAME is required}"
DISPLAY_NAME="${DISPLAY_NAME:?DISPLAY_NAME is required}"

# Core logic
gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
  --project="${PROJECT_ID}" \
  --display-name="${DISPLAY_NAME}"
