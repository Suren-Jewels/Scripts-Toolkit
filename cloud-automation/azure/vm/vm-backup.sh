#!/usr/bin/env bash
set -euo pipefail

# Capability: Trigger an on-demand backup for an Azure VM using an existing Recovery Services Vault.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VAULT_NAME="${VAULT_NAME:?VAULT_NAME is required}"
POLICY_NAME="${POLICY_NAME:?POLICY_NAME is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"

# Core logic
az backup protection backup-now \
  --resource-group "${RESOURCE_GROUP}" \
  --vault-name "${VAULT_NAME}" \
  --item-name "${VM_NAME}" \
  --policy-name "${POLICY_NAME}" \
  --workload-type "AzureVM"
