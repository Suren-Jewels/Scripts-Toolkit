#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Automation Runbook.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
RUNBOOK_NAME="${RUNBOOK_NAME:?RUNBOOK_NAME is required}"
RUNBOOK_TYPE="${RUNBOOK_TYPE:?RUNBOOK_TYPE is required}"   # PowerShell or Python2

# Optional variables
DESCRIPTION="${DESCRIPTION:-}"

# Core logic
az automation runbook create \
  --name "${RUNBOOK_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --type "${RUNBOOK_TYPE}" \
  --description "${DESCRIPTION}"
