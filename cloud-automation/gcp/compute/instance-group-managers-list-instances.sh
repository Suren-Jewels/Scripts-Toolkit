#!/usr/bin/env bash
set -euo pipefail

# Capability: List instances in a managed instance group (MIG) in Google Compute Engine.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"

# Core logic
gcloud compute instance-groups managed list-instances "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}"
