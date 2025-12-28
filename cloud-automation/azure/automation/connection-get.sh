#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve an Azure Automation connection.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
CONNECTION_NAME="${CONNECTION_NAME:?CONNECTION_NAME is required}"

# Core logic
az automation connection show \
  --name "${CONNECTION_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
