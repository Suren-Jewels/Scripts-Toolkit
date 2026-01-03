#!/usr/bin/env bash
# Capability: Validate canary success before proceeding to next rollout phase.

set -euo pipefail

HOSTS_FILE="${1:?Usage: canary-health-gate.sh <hosts.txt>}"

echo "=== Running canary health gate ==="

while read -r host; do
    [ -z "$host" ] && continue

    echo "Checking $host..."

    ssh "$host" "systemctl is-system-running --quiet" \
        || { echo "[FAIL] $host failed health check"; exit 1; }

    ssh "$host" "ping -c1 8.8.8.8 >/dev/null 2>&1" \
        || { echo "[FAIL] $host network check failed"; exit 1; }

    echo "[OK] $host passed"
done < "$HOSTS_FILE"

echo "[CANARY HEALTH GATE PASSED]"
