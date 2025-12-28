#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a Google Compute Engine instance template.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
TEMPLATE_NAME="${TEMPLATE_NAME:?TEMPLATE_NAME is required}"

# Core logic
gcloud compute instance-templates delete "${TEMPLATE_NAME}" \
  --project="${PROJECT_ID}" \
  --quiet
