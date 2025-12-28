#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Entra ID security group.

# Required variables
DISPLAY_NAME="${DISPLAY_NAME:?DISPLAY_NAME is required}"
MAIL_NICKNAME="${MAIL_NICKNAME:?MAIL_NICKNAME is required}"

# Core logic
az ad group create \
  --display-name "${DISPLAY_NAME}" \
  --mail-nickname "${MAIL_NICKNAME}"
