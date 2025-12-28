#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a key in Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
KEY_NAME="${KEY_NAME:?KEY_NAME is required}"
KEY_TYPE="${KEY_TYPE:?KEY_TYPE is required}"
# Example: KEY_TYPE="RSA" or "EC"

# Core logic
az keyvault key create \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${KEY_NAME}" \
  --kty "${KEY_TYPE}"
