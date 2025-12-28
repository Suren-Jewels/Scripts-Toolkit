#!/usr/bin/env bash
set -euo pipefail

# Capability: Remove a directory role assignment from an Entra ID user.

# Required variables
ROLE_NAME="${ROLE_NAME:?ROLE_NAME is required}"
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"

# Core logic
az role assignment delete \
  --assignee "${USER_PRINCIPAL_NAME}" \
  --role "${ROLE_NAME}"
