#!/usr/bin/env bash
set -euo pipefail

# Capability: Set target pools for a managed instance group (MIG).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
TARGET_POOLS="${TARGET_POOLS:?TARGET_POOLS is required}"
# Format example: "pool-1,pool-2"

# Core logic
gcloud compute instance-groups managed set-target-pools "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --target-pools="${TARGET_POOLS}"
