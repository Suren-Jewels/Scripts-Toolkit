#!/usr/bin/env bash
set -euo pipefail

# Capability: Set (create or update) a secret in Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
SECRET_NAME="${SECRET_NAME:?SECRET_NAME is required}"
SECRET_VALUE="${SECRET_VALUE:?SECRET_VALUE is required}"

# Core logic
az keyvault secret set \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${SECRET_NAME}" \
  --value "${SECRET_VALUE}"
