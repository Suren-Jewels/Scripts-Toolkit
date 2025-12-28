#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve an Azure Automation credential.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
CREDENTIAL_NAME="${CREDENTIAL_NAME:?CREDENTIAL_NAME is required}"

# Core logic
az automation credential show \
  --name "${CREDENTIAL_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
