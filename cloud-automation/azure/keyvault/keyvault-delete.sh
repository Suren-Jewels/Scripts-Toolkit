#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Key Vault.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"

# Core logic
az keyvault delete \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${KEYVAULT_NAME}"
