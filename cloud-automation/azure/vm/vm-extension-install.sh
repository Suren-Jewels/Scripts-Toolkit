#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
EXTENSION_NAME="${EXTENSION_NAME:?EXTENSION_NAME is required}"
PUBLISHER="${PUBLISHER:?PUBLISHER is required}"
TYPE="${TYPE:?TYPE is required}"
TYPE_HANDLER_VERSION="${TYPE_HANDLER_VERSION:?TYPE_HANDLER_VERSION is required}"
SETTINGS_FILE="${SETTINGS_FILE:-}"
PROTECTED_SETTINGS_FILE="${PROTECTED_SETTINGS_FILE:-}"

# Core logic
ARGS=(
  --resource-group "${RESOURCE_GROUP}"
  --vm-name "${VM_NAME}"
  --name "${EXTENSION_NAME}"
  --publisher "${PUBLISHER}"
  --extension-type "${TYPE}"
  --type-handler-version "${TYPE_HANDLER_VERSION}"
)

if [ -n "${SETTINGS_FILE}" ]; then
  ARGS+=(--settings "${SETTINGS_FILE}")
fi

if [ -n "${PROTECTED_SETTINGS_FILE}" ]; then
  ARGS+=(--protected-settings "${PROTECTED_SETTINGS_FILE}")
fi

az vm extension set "${ARGS[@]}"
