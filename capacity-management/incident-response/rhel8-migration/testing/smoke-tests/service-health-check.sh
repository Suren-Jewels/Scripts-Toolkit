#!/usr/bin/env bash
# Capability: Validate critical service health.

set -euo pipefail

SERVICES=("sshd" "chronyd" "network" "firewalld")

echo "=== Running Service Health Check ==="

for svc in "${SERVICES[@]}"; do
    echo "Checking $svc..."
    systemctl is-active --quiet "$svc" \
        && echo "  [OK] $svc active" \
        || { echo "  [FAIL] $svc inactive"; exit 1; }
done

echo "[SERVICE HEALTH CHECK PASSED]"
