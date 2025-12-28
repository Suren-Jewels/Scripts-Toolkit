#!/usr/bin/env bash
set -euo pipefail

# Capability: Link an Azure Automation runbook to a schedule.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
SCHEDULE_NAME="${SCHEDULE_NAME:?SCHEDULE_NAME is required}"
RUNBOOK_NAME="${RUNBOOK_NAME:?RUNBOOK_NAME is required}"

# Core logic
az automation runbook schedule add \
  --runbook-name "${RUNBOOK_NAME}" \
  --schedule-name "${SCHEDULE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
