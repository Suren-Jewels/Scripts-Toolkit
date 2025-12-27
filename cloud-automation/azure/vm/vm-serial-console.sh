#!/usr/bin/env bash
set -euo pipefail

# Capability: Enable and access the Azure VM serial console for troubleshooting.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"

# Core logic
az vm boot-diagnostics enable \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}"

az vm boot-diagnostics get-boot-log \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}"
