#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a key from Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
KEY_NAME="${KEY_NAME:?KEY_NAME is required}"

# Core logic
az keyvault key delete \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${KEY_NAME}"
