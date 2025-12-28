#!/usr/bin/env bash
set -euo pipefail

# Capability: Set an access policy on an Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
OBJECT_ID="${OBJECT_ID:?OBJECT_ID is required}"
PERMISSIONS="${PERMISSIONS:?PERMISSIONS is required}"
# Example: PERMISSIONS="keys=get,list secrets=get,list certificates=get,list"

# Core logic
az keyvault set-policy \
  --name "${KEYVAULT_NAME}" \
  --object-id "${OBJECT_ID}" \
  ${PERMISSIONS}
