#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a blob container in an Azure Storage Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"
CONTAINER_NAME="${CONTAINER_NAME:?CONTAINER_NAME is required}"

# Core logic
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login \
  --resource-group "${RESOURCE_GROUP}"
