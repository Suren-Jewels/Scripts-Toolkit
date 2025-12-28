#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve output from an Azure Automation Job.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
JOB_ID="${JOB_ID:?JOB_ID is required}"

# Core logic
az automation job output \
  --job-id "${JOB_ID}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}"
