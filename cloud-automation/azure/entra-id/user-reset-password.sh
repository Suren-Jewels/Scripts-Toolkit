#!/usr/bin/env bash
set -euo pipefail

# Capability: Reset an Entra ID user's password.

# Required variables
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"
NEW_PASSWORD="${NEW_PASSWORD:?NEW_PASSWORD is required}"

# Optional variables
FORCE_CHANGE_PASSWORD_NEXT_LOGIN="${FORCE_CHANGE_PASSWORD_NEXT_LOGIN:-true}"

# Core logic
az ad user update \
  --id "${USER_PRINCIPAL_NAME}" \
  --password "${NEW_PASSWORD}" \
  --force-change-password-next-login "${FORCE_CHANGE_PASSWORD_NEXT_LOGIN}"
