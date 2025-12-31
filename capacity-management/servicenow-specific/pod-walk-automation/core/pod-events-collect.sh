#!/usr/bin/env bash
# Capability: Collect Kubernetes events for all pods.
# Output structure:
# events/<namespace>/<pod>.events.json

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

OUTPUT_DIR="${OUTPUT_DIR:-events}"
mkdir -p "$OUTPUT_DIR"

namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

for ns in $namespaces; do
    mkdir -p "$OUTPUT_DIR/$ns"
    pods=$(kubectl get pods -n "$ns" -o jsonpath='{.items[*].metadata.name}')

    for pod in $pods; do
        kubectl get events -n "$ns" --field-selector involvedObject.name="$pod" -o json \
            > "$OUTPUT_DIR/$ns/$pod.events.json" 2>/dev/null || true
    done
done

echo "Events collected under: $OUTPUT_DIR"
