#!/usr/bin/env bash
# Capability: Safely drain a reserve pool node.
# Drains workloads while respecting system-critical pods.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

kubectl drain "$NODE_NAME" \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force

echo "Reserve node drained: $NODE_NAME"
