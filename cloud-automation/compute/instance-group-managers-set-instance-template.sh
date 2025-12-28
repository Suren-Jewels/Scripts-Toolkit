#!/usr/bin/env bash
set -euo pipefail

# Capability: Set the instance template for a managed instance group (MIG).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
TEMPLATE_NAME="${TEMPLATE_NAME:?TEMPLATE_NAME is required}"

# Core logic
gcloud compute instance-groups managed set-instance-template "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --template="${TEMPLATE_NAME}"
