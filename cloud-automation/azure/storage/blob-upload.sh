#!/usr/bin/env bash
set -euo pipefail

# Capability: Upload a blob to an Azure Storage container.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"
CONTAINER_NAME="${CONTAINER_NAME:?CONTAINER_NAME is required}"
FILE_PATH="${FILE_PATH:?FILE_PATH is required}"

# Core logic
az storage blob upload \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --container-name "${CONTAINER_NAME}" \
  --name "$(basename "${FILE_PATH}")" \
  --file "${FILE_PATH}" \
  --auth-mode login \
  --resource-group "${RESOURCE_GROUP}"
