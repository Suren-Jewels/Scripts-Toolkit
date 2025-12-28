#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Automation Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"

# Core logic
az automation account delete \
  --name "${AUTOMATION_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --yes
