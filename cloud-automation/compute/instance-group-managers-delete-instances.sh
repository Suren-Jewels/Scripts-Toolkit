#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete instances from a managed instance group (MIG) in Google Compute Engine.
# This deletes the underlying VM instances and updates the MIG accordingly.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
INSTANCE_NAMES="${INSTANCE_NAMES:?INSTANCE_NAMES is required}"
# Format example: "instance-1,instance-2"

# Core logic
gcloud compute instance-groups managed delete-instances "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --instances="${INSTANCE_NAMES}" \
  --quiet
