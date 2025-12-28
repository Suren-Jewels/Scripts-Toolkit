#!/usr/bin/env bash
set -euo pipefail

# Capability: Create or update an Azure Automation variable.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
VARIABLE_NAME="${VARIABLE_NAME:?VARIABLE_NAME is required}"
VARIABLE_VALUE="${VARIABLE_VALUE:?VARIABLE_VALUE is required}"

# Optional variables
DESCRIPTION="${DESCRIPTION:-}"
ENCRYPTED="${ENCRYPTED:-false}"

# Core logic
az automation variable create \
  --name "${VARIABLE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --value "${VARIABLE_VALUE}" \
  --description "${DESCRIPTION}" \
  --encrypted "${ENCRYPTED}"
