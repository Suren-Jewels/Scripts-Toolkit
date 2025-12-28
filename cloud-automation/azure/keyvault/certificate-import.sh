#!/usr/bin/env bash
set -euo pipefail

# Capability: Import a certificate into Azure Key Vault.

# Required variables
KEYVAULT_NAME="${KEYVAULT_NAME:?KEYVAULT_NAME is required}"
CERT_NAME="${CERT_NAME:?CERT_NAME is required}"
CERT_FILE="${CERT_FILE:?CERT_FILE is required}"
# Example: CERT_FILE="/path/to/cert.pfx"

# Optional password for PFX files
CERT_PASSWORD="${CERT_PASSWORD:-}"

# Core logic
az keyvault certificate import \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${CERT_NAME}" \
  --file "${CERT_FILE}" \
  ${CERT_PASSWORD:+--password "${CERT_PASSWORD}"}
