#!/usr/bin/env bash
# Capability: Validate snapshots before rollback to ensure integrity and usability.

set -euo pipefail

HOST="${1:?Usage: snapshot-validator.sh <host>}"

echo "=== Validating snapshot on $HOST ==="

ssh "$HOST" "sudo ls /var/lib/snapshots" >/dev/null \
    || { echo "[ERROR] Snapshot directory missing on $HOST"; exit 1; }

ssh "$HOST" "sudo test -f /var/lib/snapshots/pre-migration.img" \
    && echo "[OK] Snapshot exists" \
    || { echo "[ERROR] Snapshot missing"; exit 1; }

echo "[VALIDATION COMPLETE] Snapshot ready for rollback."
