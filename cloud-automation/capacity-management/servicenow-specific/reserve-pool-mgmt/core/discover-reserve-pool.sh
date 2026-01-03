#!/usr/bin/env bash
# Capability: Discover all reserve pool nodes.
# Identifies nodes using label: reserve-pool=true

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

LABEL_KEY="${LABEL_KEY:-reserve-pool}"
LABEL_VALUE="${LABEL_VALUE:-true}"

nodes=$(kubectl get nodes -l "$LABEL_KEY=$LABEL_VALUE" -o json)

echo "$nodes" | jq -r '
  .items[] |
  {
    name: .metadata.name,
    labels: .metadata.labels,
    capacity: .status.capacity,
    allocatable: .status.allocatable
  }
'
