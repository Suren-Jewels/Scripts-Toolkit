#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve details for an Entra ID user.

# Required variables
USER_PRINCIPAL_NAME="${USER_PRINCIPAL_NAME:?USER_PRINCIPAL_NAME is required}"

# Core logic
az ad user show \
  --id "${USER_PRINCIPAL_NAME}"
