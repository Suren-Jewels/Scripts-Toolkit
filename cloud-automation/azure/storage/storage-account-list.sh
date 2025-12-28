#!/usr/bin/env bash
set -euo pipefail

# Capability: List all storage accounts in a resource group or subscription.

# Optional variables
RESOURCE_GROUP="${RESOURCE_GROUP:-}"

# Core logic
if [ -n "${RESOURCE_GROUP}" ]; then
  az storage account list \
    --resource-group "${RESOURCE_GROUP}"
else
  az storage account list
fi
