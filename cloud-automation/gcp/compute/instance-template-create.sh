#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a Google Compute Engine instance template.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
TEMPLATE_NAME="${TEMPLATE_NAME:?TEMPLATE_NAME is required}"
MACHINE_TYPE="${MACHINE_TYPE:?MACHINE_TYPE is required}"
IMAGE_FAMILY="${IMAGE_FAMILY:?IMAGE_FAMILY is required}"
IMAGE_PROJECT="${IMAGE_PROJECT:?IMAGE_PROJECT is required}"

# Core logic
gcloud compute instance-templates create "${TEMPLATE_NAME}" \
  --project="${PROJECT_ID}" \
  --machine-type="${MACHINE_TYPE}" \
  --image-family="${IMAGE_FAMILY}" \
  --image-project="${IMAGE_PROJECT}"
