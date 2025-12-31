#!/usr/bin/env bash
# Capability: Collect logs for all Kubernetes pods.
# Output structure:
# logs/<namespace>/<pod>.log

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

OUTPUT_DIR="${OUTPUT_DIR:-logs}"
mkdir -p "$OUTPUT_DIR"

namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

for ns in $namespaces; do
    mkdir -p "$OUTPUT_DIR/$ns"
    pods=$(kubectl get pods -n "$ns" -o jsonpath='{.items[*].metadata.name}')

    for pod in $pods; do
        kubectl logs -n "$ns" "$pod" > "$OUTPUT_DIR/$ns/$pod.log" 2>/dev/null || true
    done
done

echo "Logs collected under: $OUTPUT_DIR"
