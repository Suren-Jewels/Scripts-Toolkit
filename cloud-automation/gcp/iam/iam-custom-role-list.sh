#!/usr/bin/env bash
set -euo pipefail

# Capability: List custom IAM roles in a Google Cloud project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud iam roles list \
  --project="${PROJECT_ID}" \
  --format=json
