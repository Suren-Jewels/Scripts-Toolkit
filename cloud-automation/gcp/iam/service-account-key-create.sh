#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a key for a Google Cloud service account.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_EMAIL:?SERVICE_ACCOUNT_EMAIL is required}"
OUTPUT_FILE="${OUTPUT_FILE:?OUTPUT_FILE is required}"

# Core logic
gcloud iam service-accounts keys create "${OUTPUT_FILE}" \
  --iam-account="${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}"
