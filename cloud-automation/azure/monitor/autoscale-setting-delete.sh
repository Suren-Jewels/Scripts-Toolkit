#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an autoscale setting in Azure Monitor.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOSCALE_NAME="${AUTOSCALE_NAME:?AUTOSCALE_NAME is required}"

# Core logic
az monitor autoscale delete \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${AUTOSCALE_NAME}"
