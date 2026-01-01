#!/usr/bin/env bash
# Capability: Discover all managed servers.
# Identifies servers using label: server-managed=true (or overridden via env)

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

LABEL_KEY="${LABEL_KEY:-server-managed}"
LABEL_VALUE="${LABEL_VALUE:-true}"

servers=$(kubectl get nodes -l "$LABEL_KEY=$LABEL_VALUE" -o json)

echo "$servers" | jq -r '
  .items[] |
  {
    name: .metadata.name,
    labels: .metadata.labels,
    capacity: .status.capacity,
    allocatable: .status.allocatable
  }
'
