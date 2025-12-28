#!/usr/bin/env bash
set -euo pipefail

# Capability: Get metadata for an Azure Automation Runbook (draft + published state).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
RUNBOOK_NAME="${RUNBOOK_NAME:?RUNBOOK_NAME is required}"

# Core logic
az automation runbook show \
  --name "${RUNBOOK_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
