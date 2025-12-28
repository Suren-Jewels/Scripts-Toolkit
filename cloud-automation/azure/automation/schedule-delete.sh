#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Automation schedule.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
SCHEDULE_NAME="${SCHEDULE_NAME:?SCHEDULE_NAME is required}"

# Core logic
az automation schedule delete \
  --name "${SCHEDULE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --yes
