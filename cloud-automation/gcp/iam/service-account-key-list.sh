#!/usr/bin/env bash
set -euo pipefail

# Capability: List keys for a Google Cloud service account.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_EMAIL:?SERVICE_ACCOUNT_EMAIL is required}"

# Core logic
gcloud iam service-accounts keys list \
  --iam-account="${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}"
