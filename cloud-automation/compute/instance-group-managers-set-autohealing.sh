#!/usr/bin/env bash
set -euo pipefail

# Capability: Configure autohealing policies for a managed instance group (MIG).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
HEALTH_CHECK_NAME="${HEALTH_CHECK_NAME:?HEALTH_CHECK_NAME is required}"
INITIAL_DELAY_SEC="${INITIAL_DELAY_SEC:?INITIAL_DELAY_SEC is required}"

# Core logic
gcloud compute instance-groups managed set-autohealing "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --health-check="${HEALTH_CHECK_NAME}" \
  --initial-delay="${INITIAL_DELAY_SEC}"
