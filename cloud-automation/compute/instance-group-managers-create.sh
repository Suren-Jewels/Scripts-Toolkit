#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a managed instance group (MIG) in Google Compute Engine.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
TEMPLATE_NAME="${TEMPLATE_NAME:?TEMPLATE_NAME is required}"
TARGET_SIZE="${TARGET_SIZE:?TARGET_SIZE is required}"

# Core logic
gcloud compute instance-groups managed create "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --base-instance-name="${INSTANCE_GROUP_MANAGER_NAME}" \
  --template="${TEMPLATE_NAME}" \
  --size="${TARGET_SIZE}"
