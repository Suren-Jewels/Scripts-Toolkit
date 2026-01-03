#!/usr/bin/env bash
# Capability: Decommission a managed server.
# Removes server from scheduling and clears management labels.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

LABEL_KEY="${LABEL_KEY:-server-managed}"

# Mark unschedulable
kubectl cordon "$NODE_NAME"

# Remove management label
kubectl label node "$NODE_NAME" "$LABEL_KEY"- --overwrite

echo "Server decommissioned: $NODE_NAME"
