#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an autoscale setting in Azure Monitor.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOSCALE_NAME="${AUTOSCALE_NAME:?AUTOSCALE_NAME is required}"
TARGET_RESOURCE_ID="${TARGET_RESOURCE_ID:?TARGET_RESOURCE_ID is required}"
MIN_COUNT="${MIN_COUNT:?MIN_COUNT is required}"
MAX_COUNT="${MAX_COUNT:?MAX_COUNT is required}"
DEFAULT_COUNT="${DEFAULT_COUNT:?DEFAULT_COUNT is required}"

# Core logic
az monitor autoscale create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${AUTOSCALE_NAME}" \
  --resource "${TARGET_RESOURCE_ID}" \
  --min-count "${MIN_COUNT}" \
  --max-count "${MAX_COUNT}" \
  --count "${DEFAULT_COUNT}"
