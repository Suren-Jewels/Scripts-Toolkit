#!/usr/bin/env bash
set -euo pipefail

# Capability: Update autoscaling configuration for a managed instance group (MIG).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_MANAGER_NAME="${INSTANCE_GROUP_MANAGER_NAME:?INSTANCE_GROUP_MANAGER_NAME is required}"
AUTOSCALER_NAME="${AUTOSCALER_NAME:?AUTOSCALER_NAME is required}"
MIN_SIZE="${MIN_SIZE:?MIN_SIZE is required}"
MAX_SIZE="${MAX_SIZE:?MAX_SIZE is required}"
TARGET_CPU_UTILIZATION="${TARGET_CPU_UTILIZATION:?TARGET_CPU_UTILIZATION is required}"

# Core logic
gcloud compute instance-groups managed set-autoscaling "${INSTANCE_GROUP_MANAGER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --autoscaler="${AUTOSCALER_NAME}" \
  --min-num-replicas="${MIN_SIZE}" \
  --max-num-replicas="${MAX_SIZE}" \
  --target-cpu-utilization="${TARGET_CPU_UTILIZATION}"
