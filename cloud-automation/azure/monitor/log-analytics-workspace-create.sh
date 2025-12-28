#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Log Analytics Workspace.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
WORKSPACE_NAME="${WORKSPACE_NAME:?WORKSPACE_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
az monitor log-analytics workspace create \
  --resource-group "${RESOURCE_GROUP}" \
  --workspace-name "${WORKSPACE_NAME}" \
  --location "${LOCATION}"
