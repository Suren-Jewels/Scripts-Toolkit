#!/usr/bin/env bash
set -euo pipefail

# Capability: Create or update an Azure Automation connection.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
CONNECTION_NAME="${CONNECTION_NAME:?CONNECTION_NAME is required}"
CONNECTION_TYPE="${CONNECTION_TYPE:?CONNECTION_TYPE is required}"

# Optional: JSON string of key-value pairs for connection fields
FIELDS_JSON="${FIELDS_JSON:-}"

# Core logic
if [ -n "${FIELDS_JSON}" ]; then
  az automation connection create \
    --name "${CONNECTION_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
    --connection-type-name "${CONNECTION_TYPE}" \
    --fields "${FIELDS_JSON}"
else
  az automation connection create \
    --name "${CONNECTION_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
    --connection-type-name "${CONNECTION_TYPE}"
fi
