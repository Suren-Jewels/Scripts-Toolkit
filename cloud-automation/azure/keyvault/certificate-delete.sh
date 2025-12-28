#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a certificate from Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
CERT_NAME="${CERT_NAME:?CERT_NAME is required}"

# Core logic
az keyvault certificate delete \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${CERT_NAME}"
