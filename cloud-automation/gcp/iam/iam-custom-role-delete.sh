#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a custom IAM role in a Google Cloud project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ROLE_ID="${ROLE_ID:?ROLE_ID is required}"

# Core logic
gcloud iam roles delete "${ROLE_ID}" \
  --project="${PROJECT_ID}" \
  --quiet
