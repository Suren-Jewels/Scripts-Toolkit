#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
COMMAND_ID="${COMMAND_ID:?COMMAND_ID is required}"
SCRIPT_FILE="${SCRIPT_FILE:-}"
PARAMETERS="${PARAMETERS:-}"

# Core logic
ARGS=(
  --resource-group "${RESOURCE_GROUP}"
  --name "${VM_NAME}"
  --command-id "${COMMAND_ID}"
)

if [ -n "${SCRIPT_FILE}" ]; then
  ARGS+=(--scripts @"${SCRIPT_FILE}")
fi

if [ -n "${PARAMETERS}" ]; then
  ARGS+=(--parameters "${PARAMETERS}")
fi

az vm run-command invoke "${ARGS[@]}"
