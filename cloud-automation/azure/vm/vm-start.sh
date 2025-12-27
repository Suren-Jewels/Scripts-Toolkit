#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"

# Core logic
az vm start \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}"
