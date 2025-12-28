#!/usr/bin/env bash
set -euo pipefail

# Capability: List Azure Automation Accounts.

# Optional variables
RESOURCE_GROUP="${RESOURCE_GROUP:-}"

# Core logic
if [ -n "${RESOURCE_GROUP}" ]; then
  az automation account list \
    --resource-group "${RESOURCE_GROUP}"
else
  az automation account list
fi
