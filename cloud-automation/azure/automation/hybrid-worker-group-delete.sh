#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Automation Hybrid Worker Group.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AUTOMATION_ACCOUNT_NAME="${AUTOMATION_ACCOUNT_NAME:?AUTOMATION_ACCOUNT_NAME is required}"
HYBRID_WORKER_GROUP_NAME="${HYBRID_WORKER_GROUP_NAME:?HYBRID_WORKER_GROUP_NAME is required}"

# Core logic
az automation hybrid-runbook-worker-group delete \
  --name "${HYBRID_WORKER_GROUP_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --automation-account-name "${AUTOMATION_ACCOUNT_NAME}" \
  --yes
