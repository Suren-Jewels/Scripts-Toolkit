#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Key Vault.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"
SKU="${SKU:?SKU is required}"
# Example: SKU="standard" or "premium"

# Core logic
az keyvault create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${KEYVAULT_NAME}" \
  --location "${LOCATION}" \
  --sku "${SKU}"
