#!/usr/bin/env bash
set -euo pipefail

# Capability: List all blobs in an Azure Storage container.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"
CONTAINER_NAME="${CONTAINER_NAME:?CONTAINER_NAME is required}"

# Core logic
az storage blob list \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --container-name "${CONTAINER_NAME}" \
  --auth-mode login \
  --resource-group "${RESOURCE_GROUP}"
