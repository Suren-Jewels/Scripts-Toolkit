#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve a secret value from Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
SECRET_NAME="${SECRET_NAME:?SECRET_NAME is required}"

# Core logic
az keyvault secret show \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${SECRET_NAME}" \
  --query value \
  --output tsv
