#!/usr/bin/env bash
set -euo pipefail

# Capability: List all blob containers in an Azure Storage Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"

# Core logic
az storage container list \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login \
  --resource-group "${RESOURCE_GROUP}"
