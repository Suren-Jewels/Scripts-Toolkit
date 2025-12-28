#!/usr/bin/env bash
set -euo pipefail

# Capability: Run a Kusto query against a Log Analytics Workspace.

# Required variables
WORKSPACE_ID="${WORKSPACE_ID:?WORKSPACE_ID is required}"
QUERY="${QUERY:?QUERY is required}"

# Core logic
az monitor log-analytics query \
  --workspace "${WORKSPACE_ID}" \
  --analytics-query "${QUERY}"
