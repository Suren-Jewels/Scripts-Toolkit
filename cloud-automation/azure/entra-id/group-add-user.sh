#!/usr/bin/env bash
set -euo pipefail

# Capability: Add a user to an Entra ID security group.

# Required variables
GROUP_ID="${GROUP_ID:?GROUP_ID is required}"
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"

# Core logic
az ad group member add \
  --group "${GROUP_ID}" \
  --member-id "$(az ad user show --id "${USER_PRINCIPAL_NAME}" --query id -o tsv)"
