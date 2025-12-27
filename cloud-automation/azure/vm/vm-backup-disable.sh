#!/usr/bin/env bash
set -euo pipefail

# Capability: Disable backup protection for an Azure VM.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VAULT_NAME="${VAULT_NAME:?VAULT_NAME is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"

# Core logic
az backup protection disable \
  --resource-group "${RESOURCE_GROUP}" \
  --vault-name "${VAULT_NAME}" \
  --item-name "${VM_NAME}" \
  --workload-type "AzureVM" \
  --yes
