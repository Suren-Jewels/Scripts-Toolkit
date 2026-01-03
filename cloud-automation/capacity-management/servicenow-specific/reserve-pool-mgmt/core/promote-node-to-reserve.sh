#!/usr/bin/env bash
# Capability: Promote a node into the reserve pool.
# Applies label: reserve-pool=true (or overridden via env)

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

LABEL_KEY="${LABEL_KEY:-reserve-pool}"
LABEL_VALUE="${LABEL_VALUE:-true}"

kubectl label node "$NODE_NAME" "$LABEL_KEY=$LABEL_VALUE" --overwrite

echo "Node promoted to reserve pool: $NODE_NAME"
