#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a Google Compute Engine instance.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_NAME="${INSTANCE_NAME:?INSTANCE_NAME is required}"
MACHINE_TYPE="${MACHINE_TYPE:?MACHINE_TYPE is required}"
IMAGE_FAMILY="${IMAGE_FAMILY:?IMAGE_FAMILY is required}"
IMAGE_PROJECT="${IMAGE_PROJECT:?IMAGE_PROJECT is required}"

# Core logic
gcloud compute instances create "${INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --machine-type="${MACHINE_TYPE}" \
  --image-family="${IMAGE_FAMILY}" \
  --image-project="${IMAGE_PROJECT}"
