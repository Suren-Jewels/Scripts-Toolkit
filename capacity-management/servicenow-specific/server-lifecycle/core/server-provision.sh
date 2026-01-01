#!/usr/bin/env bash
# Capability: Provision a new server into the managed fleet.
# Applies baseline labels and registers the server as managed.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

LABEL_KEY="${LABEL_KEY:-server-managed}"
LABEL_VALUE="${LABEL_VALUE:-true}"

# Register server into managed fleet via label
kubectl label node "$NODE_NAME" "$LABEL_KEY=$LABEL_VALUE" --overwrite

echo "Server provisioned and registered: $NODE_NAME"
