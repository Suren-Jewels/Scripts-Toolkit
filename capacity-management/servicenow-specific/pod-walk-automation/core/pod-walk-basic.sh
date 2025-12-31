#!/usr/bin/env bash
# Capability: Basic Kubernetes pod walk.
# Collects:
# - Pod name
# - Namespace
# - Phase
# - Restart count
# - Node name

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

pods=$(kubectl get pods --all-namespaces -o json)

echo "$pods" | jq -r '
  .items[] |
  {
    name: .metadata.name,
    namespace: .metadata.namespace,
    phase: .status.phase,
    restarts: (.status.containerStatuses // [] | map(.restartCount) | add // 0),
    node: .spec.nodeName
  }
'
