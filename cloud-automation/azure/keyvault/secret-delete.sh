#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a secret from Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
SECRET_NAME="${SECRET_NAME:?SECRET_NAME is required}"

# Core logic
az keyvault secret delete \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${SECRET_NAME}"
