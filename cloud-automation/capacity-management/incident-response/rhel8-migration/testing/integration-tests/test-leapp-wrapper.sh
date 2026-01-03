#!/usr/bin/env bash
# Capability: Test LEAPP automation wrapper end‑to‑end.

set -euo pipefail

echo "=== Testing LEAPP Wrapper ==="

HOST="${1:?Usage: test-leapp-wrapper.sh <host>}"

ssh "$HOST" "sudo leapp preupgrade --target 8" >/dev/null 2>&1 \
    && echo "[OK] Preupgrade executed" \
    || { echo "[FAIL] Preupgrade failed"; exit 1; }

ssh "$HOST" "sudo leapp upgrade" >/dev/null 2>&1 \
    && echo "[OK] Upgrade executed" \
    || { echo "[FAIL] Upgrade failed"; exit 1; }

echo "[LEAPP WRAPPER TEST PASSED]"
