#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Log Analytics Workspace.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
WORKSPACE_NAME="${WORKSPACE_NAME:?WORKSPACE_NAME is required}"

# Core logic
az monitor log-analytics workspace delete \
  --resource-group "${RESOURCE_GROUP}" \
  --workspace-name "${WORKSPACE_NAME}" \
  --yes
