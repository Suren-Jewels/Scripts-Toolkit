#!/usr/bin/env bash
set -euo pipefail

# Capability: Recreate instances in a managed instance group (MIG) in Google Compute Engine.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
INSTANCE_NAMES="${INSTANCE_NAMES:?INSTANCE_NAMES is required}"
# Format example: "instance-1,instance-2"

# Core logic
gcloud compute instance-groups managed recreate-instances "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --instances="${INSTANCE_NAMES}"
