#!/usr/bin/env bash
set -euo pipefail

# Capability: Update an Azure Automation schedule.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
SCHEDULE_NAME="${SCHEDULE_NAME:?SCHEDULE_NAME is required}"

# Optional variables
START_TIME="${START_TIME:-}"
FREQUENCY="${FREQUENCY:-}"
INTERVAL="${INTERVAL:-}"
DESCRIPTION="${DESCRIPTION:-}"

# Core logic
az automation schedule update \
  --name "${SCHEDULE_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  ${START_TIME:+--start-time "${START_TIME}"} \
  ${FREQUENCY:+--frequency "${FREQUENCY}"} \
  ${INTERVAL:+--interval "${INTERVAL}"} \
  ${DESCRIPTION:+--description "${DESCRIPTION}"}
