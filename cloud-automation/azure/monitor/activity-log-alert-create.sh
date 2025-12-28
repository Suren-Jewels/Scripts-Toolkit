#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Activity Log alert in Azure Monitor.

# Required variables
ALERT_NAME="${ALERT_NAME:?ALERT_NAME is required}"
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
SCOPE="${SCOPE:?SCOPE is required}"
# Example: SCOPE="/subscriptions/<id>"

CONDITION="${CONDITION:?CONDITION is required}"
# Example: CONDITION="category=Administrative and level=Error"

# Core logic
az monitor activity-log alert create \
  --name "${ALERT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --scope "${SCOPE}" \
  --condition "${CONDITION}"
