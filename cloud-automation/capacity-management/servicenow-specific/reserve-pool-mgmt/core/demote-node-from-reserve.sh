#!/usr/bin/env bash
# Capability: Demote a node from the reserve pool.
# Removes label: reserve-pool=true (or overridden via env)

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

LABEL_KEY="${LABEL_KEY:-reserve-pool}"

kubectl label node "$NODE_NAME" "$LABEL_KEY"- || true

echo "Node demoted from reserve pool: $NODE_NAME"
