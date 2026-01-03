#!/usr/bin/env bash
# Capability: Stress‑test rollback workflow under heavy load.

set -euo pipefail

HOSTFILE="${1:?Usage: stress-test-rollback.sh <hosts.txt>}"

echo "=== Running Rollback Stress Test ==="

while read -r host; do
    [ -z "$host" ] && continue

    echo "Triggering rollback on $host..."

    ssh "$host" "./rollback-runner.sh" >/dev/null 2>&1 \
        && echo "  [OK] Rollback succeeded on $host" \
        || echo "  [FAIL] Rollback failed on $host"

done < "$HOSTFILE"

echo "=== Rollback Stress Test Complete ==="
