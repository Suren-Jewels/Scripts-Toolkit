#!/usr/bin/env bash
set -euo pipefail

# Capability: List all backup jobs associated with an Azure VM.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VAULT_NAME="${VAULT_NAME:?VAULT_NAME is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"

# Core logic
az backup job list \
  --resource-group "${RESOURCE_GROUP}" \
  --vault-name "${VAULT_NAME}" \
  --query "[?contains(backupItemName, '${VM_NAME}')]"
