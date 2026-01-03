#!/usr/bin/env bash
# Capability: Return a drained reserve node back to active scheduling.
# Uncordons the node to allow workloads to be scheduled again.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

kubectl uncordon "$NODE_NAME"

echo "Reserve node returned to active pool: $NODE_NAME"
