#!/usr/bin/env bash
set -euo pipefail

# Capability: Update attributes for an Entra ID user.

# Required variables
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"

# Optional variables
DISPLAY_NAME="${DISPLAY_NAME:-}"
MAIL_NICKNAME="${MAIL_NICKNAME:-}"
ACCOUNT_ENABLED="${ACCOUNT_ENABLED:-}"

# Core logic
ARGS=(--id "${USER_PRINCIPAL_NAME}")

if [ -n "${DISPLAY_NAME}" ]; then
  ARGS+=(--display-name "${DISPLAY_NAME}")
fi

if [ -n "${MAIL_NICKNAME}" ]; then
  ARGS+=(--mail-nickname "${MAIL_NICKNAME}")
fi

if [ -n "${ACCOUNT_ENABLED}" ]; then
  ARGS+=(--account-enabled "${ACCOUNT_ENABLED}")
fi

az ad user update "${ARGS[@]}"
