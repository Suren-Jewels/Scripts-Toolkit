#!/usr/bin/env bash
set -euo pipefail

# Capability: Create or update an Azure Automation schedule.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
SCHEDULE_NAME="${SCHEDULE_NAME:?SCHEDULE_NAME is required}"
START_TIME="${START_TIME:?START_TIME is required}"   # Example: 2025-01-01T00:00:00Z
FREQUENCY="${FREQUENCY:?FREQUENCY is required}"     # OneTime | Hour | Day | Week | Month

# Optional variables
INTERVAL="${INTERVAL:-1}"
DESCRIPTION="${DESCRIPTION:-}"

# Core logic
az automation schedule create \
  --name "${SCHEDULE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --start-time "${START_TIME}" \
  --frequency "${FREQUENCY}" \
  --interval "${INTERVAL}" \
  --description "${DESCRIPTION}"
