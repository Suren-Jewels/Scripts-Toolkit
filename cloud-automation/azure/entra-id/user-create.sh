#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a new Entra ID user.

# Required variables
DISPLAY_NAME="${DISPLAY_NAME:?DISPLAY_NAME is required}"
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"
PASSWORD="${PASSWORD:?PASSWORD is required}"

# Optional variables
FORCE_CHANGE_PASSWORD_NEXT_LOGIN="${FORCE_CHANGE_PASSWORD_NEXT_LOGIN:-true}"

# Core logic
az ad user create \
  --display-name "${DISPLAY_NAME}" \
  --user-principal-name "${USER_PRINCIPAL_NAME}" \
  --password "${PASSWORD}" \
  --force-change-password-next-login "${FORCE_CHANGE_PASSWORD_NEXT_LOGIN}"
