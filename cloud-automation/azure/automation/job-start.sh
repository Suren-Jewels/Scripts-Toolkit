#!/usr/bin/env bash
set -euo pipefail

# Capability: Start an Azure Automation Runbook Job.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
RUNBOOK_NAME="${RUNBOOK_NAME:?RUNBOOK_NAME is required}"

# Optional variables
PARAMETERS="${PARAMETERS:-}"

# Core logic
if [ -n "${PARAMETERS}" ]; then
  az automation runbook start \
    --name "${RUNBOOK_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
    --parameters "${PARAMETERS}"
else
  az automation runbook start \
    --name "${RUNBOOK_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
fi
