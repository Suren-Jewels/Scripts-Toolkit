#!/usr/bin/env bash
# Capability: Validate rollback automation workflow.

set -euo pipefail

echo "=== Testing Rollback Procedure ==="

HOST="${1:?Usage: test-rollback-procedure.sh <host>}"

ssh "$HOST" "./snapshot-validator.sh" \
    && echo "[OK] Snapshot validation passed" \
    || { echo "[FAIL] Snapshot validation failed"; exit 1; }

ssh "$HOST" "./rollback-runner.sh" \
    && echo "[OK] Rollback executed" \
    || { echo "[FAIL] Rollback failed"; exit 1; }

ssh "$HOST" "systemctl is-system-running --quiet" \
    && echo "[OK] Host healthy after rollback" \
    || { echo "[FAIL] Host unhealthy post‑rollback"; exit 1; }

echo "[ROLLBACK PROCEDURE TEST PASSED]"
