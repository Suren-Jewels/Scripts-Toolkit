#!/usr/bin/env bash
# Capability: Quick post‑migration health validation.

set -euo pipefail

echo "=== Running Post‑Migration Smoke Test ==="

echo "[1/4] Checking systemd health..."
systemctl is-system-running --quiet \
    && echo "  [OK] System running normally" \
    || { echo "  [FAIL] System not healthy"; exit 1; }

echo "[2/4] Checking failed services..."
FAILED=$(systemctl --failed --no-legend --plain | wc -l)
if [ "$FAILED" -eq 0 ]; then
    echo "  [OK] No failed services"
else
    echo "  [FAIL] $FAILED failed services detected"
    exit 1
fi

echo "[3/4] Checking network reachability..."
ping -c1 8.8.8.8 >/dev/null 2>&1 \
    && echo "  [OK] Network reachable" \
    || { echo "  [FAIL] Network unreachable"; exit 1; }

echo "[4/4] Checking disk space..."
df -h >/dev/null 2>&1 \
    && echo "  [OK] Disk check passed" \
    || { echo "  [FAIL] Disk check failed"; exit 1; }

echo "[POST‑MIGRATION SMOKE TEST PASSED]"
