#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a metric alert in Azure Monitor.

# Required variables
ALERT_NAME="${ALERT_NAME:?ALERT_NAME is required}"
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"

# Core logic
az monitor metrics alert delete \
  --name "${ALERT_NAME}" \
  --resource-group "${RESOURCE_GROUP}"
