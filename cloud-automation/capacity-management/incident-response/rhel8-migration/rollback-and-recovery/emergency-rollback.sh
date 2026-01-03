#!/usr/bin/env bash
# Capability: Fast-path rollback for P1 migration incidents.

set -euo pipefail

HOST="${1:?Usage: emergency-rollback.sh <host>}"

echo "=== EMERGENCY ROLLBACK INITIATED for $HOST ==="

./snapshot-validator.sh "$HOST"

ssh "$HOST" "sudo rollbackctl restore /var/lib/snapshots/pre-migration.img"

echo "Rebooting $HOST immediately..."
ssh "$HOST" "sudo reboot"

echo "[EMERGENCY ROLLBACK COMPLETE]"
