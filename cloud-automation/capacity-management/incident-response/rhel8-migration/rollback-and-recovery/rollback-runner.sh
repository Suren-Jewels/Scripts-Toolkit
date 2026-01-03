#!/usr/bin/env bash
# Capability: Execute rollback to RHEL7 snapshot.

set -euo pipefail

HOST="${1:?Usage: rollback-runner.sh <host>}"

echo "=== Initiating rollback on $HOST ==="

ssh "$HOST" "sudo systemctl stop critical-services.target" || true
ssh "$HOST" "sudo rollbackctl restore /var/lib/snapshots/pre-migration.img"

echo "Rollback triggered. Rebooting $HOST..."
ssh "$HOST" "sudo reboot"
