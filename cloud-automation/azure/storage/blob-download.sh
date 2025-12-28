#!/usr/bin/env bash
set -euo pipefail

# Capability: Download a blob from an Azure Storage container.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"
CONTAINER_NAME="${CONTAINER_NAME:?CONTAINER_NAME is required}"
BLOB_NAME="${BLOB_NAME:?BLOB_NAME is required}"
DESTINATION_PATH="${DESTINATION_PATH:?DESTINATION_PATH is required}"

# Core logic
az storage blob download \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --container-name "${CONTAINER_NAME}" \
  --name "${BLOB_NAME}" \
  --file "${DESTINATION_PATH}" \
  --auth-mode login \
  --resource-group "${RESOURCE_GROUP}"
