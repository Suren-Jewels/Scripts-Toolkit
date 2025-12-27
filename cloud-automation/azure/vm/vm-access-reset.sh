#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
USERNAME="${USERNAME:?USERNAME is required}"
PASSWORD="${PASSWORD:-}"
SSH_KEY_PATH="${SSH_KEY_PATH:-}"
RESET_TYPE="${RESET_TYPE:?RESET_TYPE is required}" # password | ssh

# Core logic
if [ "${RESET_TYPE}" = "password" ]; then
  if [ -z "${PASSWORD}" ]; then
    echo "PASSWORD is required when RESET_TYPE=password" >&2
    exit 1
  fi

  az vm user update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${VM_NAME}" \
    --username "${USERNAME}" \
    --password "${PASSWORD}"

elif [ "${RESET_TYPE}" = "ssh" ]; then
  if [ -z "${SSH_KEY_PATH}" ]; then
    echo "SSH_KEY_PATH is required when RESET_TYPE=ssh" >&2
    exit 1
  fi

  az vm user update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${VM_NAME}" \
    --username "${USERNAME}" \
    --ssh-key-value @"${SSH_KEY_PATH}"

else
  echo "Invalid RESET_TYPE. Use 'password' or 'ssh'." >&2
  exit 1
fi
