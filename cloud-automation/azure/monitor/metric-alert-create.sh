#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a metric alert in Azure Monitor.

# Required variables
ALERT_NAME="${ALERT_NAME:?ALERT_NAME is required}"
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
SCOPE="${SCOPE:?SCOPE is required}"
# Example: SCOPE="/subscriptions/<id>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vm>"

METRIC_NAME="${METRIC_NAME:?METRIC_NAME is required}"
OPERATOR="${OPERATOR:?OPERATOR is required}"
THRESHOLD="${THRESHOLD:?THRESHOLD is required}"
WINDOW_SIZE="${WINDOW_SIZE:?WINDOW_SIZE is required}"
EVALUATION_FREQUENCY="${EVALUATION_FREQUENCY:?EVALUATION_FREQUENCY is required}"

# Core logic
az monitor metrics alert create \
  --name "${ALERT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --scopes "${SCOPE}" \
  --condition "${METRIC_NAME} ${OPERATOR} ${THRESHOLD}" \
  --window-size "${WINDOW_SIZE}" \
  --evaluation-frequency "${EVALUATION_FREQUENCY}"
