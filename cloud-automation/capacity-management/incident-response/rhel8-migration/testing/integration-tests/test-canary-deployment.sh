#!/usr/bin/env bash
# Capability: Validate canary deployment logic.

set -euo pipefail

echo "=== Testing Canary Deployment ==="

HOSTFILE="${1:?Usage: test-canary-deployment.sh <hosts.txt>}"

python3 canary-selector.py "$HOSTFILE" 10 >/tmp/canary10.json
jq '.selected_hosts | length' /tmp/canary10.json | grep -q "^10$" \
    && echo "[OK] Canary‑10 selection correct" \
    || { echo "[FAIL] Canary‑10 selection incorrect"; exit 1; }

python3 canary-selector.py "$HOSTFILE" 100 >/tmp/canary100.json
jq '.selected_hosts | length' /tmp/canary100.json | grep -q "^100$" \
    && echo "[OK] Canary‑100 selection correct" \
    || { echo "[FAIL] Canary‑100 selection incorrect"; exit 1; }

echo "[CANARY DEPLOYMENT TEST PASSED]"
