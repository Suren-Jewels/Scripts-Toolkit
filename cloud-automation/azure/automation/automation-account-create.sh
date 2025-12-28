#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Automation Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Optional variables
SKU="${SKU:-Free}"

# Core logic
az automation account create \
  --name "${AUTOMATION_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku "${SKU}"
