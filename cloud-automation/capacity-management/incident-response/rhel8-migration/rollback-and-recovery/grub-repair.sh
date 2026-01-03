#!/usr/bin/env bash
# Capability: Repair GRUB/bootloader issues after failed migration.

set -euo pipefail

HOST="${1:?Usage: grub-repair.sh <host>}"

echo "=== Repairing GRUB on $HOST ==="

ssh "$HOST" "sudo grub2-install /dev/sda"
ssh "$HOST" "sudo grub2-mkconfig -o /boot/grub2/grub.cfg"

echo "[GRUB REPAIR COMPLETE] $HOST"
