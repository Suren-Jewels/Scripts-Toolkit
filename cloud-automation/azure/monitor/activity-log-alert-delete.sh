#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Activity Log alert in Azure Monitor.

# Required variables
ALERT_NAME="${ALERT_NAME:?ALERT_NAME is required}"
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"

# Core logic
az monitor activity-log alert delete \
  --name "${ALERT_NAME}" \
  --resource-group "${RESOURCE_GROUP}"
