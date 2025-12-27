#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a managed image from an existing Azure VM
# This script captures the OS disk of a VM and produces a reusable image.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
IMAGE_NAME="${IMAGE_NAME:?IMAGE_NAME is required}"

# Optional variables
LOCATION="${LOCATION:-}"
TAGS="${TAGS:-}"

# Core logic
OS_DISK_ID=$(az vm show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --query "storageProfile.osDisk.managedDisk.id" \
  -o tsv)

ARGS=(
  --resource-group "${RESOURCE_GROUP}"
  --name "${IMAGE_NAME}"
  --source "${OS_DISK_ID}"
)

if [ -n "${LOCATION}" ]; then
  ARGS+=(--location "${LOCATION}")
fi

if [ -n "${TAGS}" ]; then
  ARGS+=(--tags "${TAGS}")
fi

az image create "${ARGS[@]}"
