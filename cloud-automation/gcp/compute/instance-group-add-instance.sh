#!/usr/bin/env bash
set -euo pipefail

# Capability: Add an instance to a Google Compute Engine instance group (unmanaged).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_NAME="${INSTANCE_GROUP_NAME:?INSTANCE_GROUP_NAME is required}"
INSTANCE_NAME="${INSTANCE_NAME:?INSTANCE_NAME is required}"

# Core logic
gcloud compute instance-groups add-instances "${INSTANCE_GROUP_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --instances="${INSTANCE_NAME}"
