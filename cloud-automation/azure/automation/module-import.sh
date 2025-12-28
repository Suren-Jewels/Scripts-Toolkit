#!/usr/bin/env bash
set -euo pipefail

# Capability: Import a module into an Azure Automation Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
MODULE_NAME="${MODULE_NAME:?MODULE_NAME is required}"
MODULE_URI="${MODULE_URI:?MODULE_URI is required}"   # URL to .zip module package

# Core logic
az automation module import \
  --name "${MODULE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --content-link-uri "${MODULE_URI}"
