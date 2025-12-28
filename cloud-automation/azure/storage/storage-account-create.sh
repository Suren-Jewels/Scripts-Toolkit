#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Storage Account.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:?STORAGE_ACCOUNT_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Optional variables
SKU="${SKU:-Standard_LRS}"
KIND="${KIND:-StorageV2}"

# Core logic
az storage account create \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku "${SKU}" \
  --kind "${KIND}"
