rollback-and-recovery/
    -> network-recovery.sh
    ->
#!/usr/bin/env bash
# Capability: Restore network configuration after migration failure.

set -euo pipefail

HOST="${1:?Usage: network-recovery.sh <host>}"

echo "=== Restoring network configuration on $HOST ==="

ssh "$HOST" "sudo cp /etc/sysconfig/network-scripts/backup-ifcfg-* /etc/sysconfig/network-scripts/" || true
ssh "$HOST" "sudo nmcli connection reload" || true
ssh "$HOST" "sudo systemctl restart NetworkManager"

echo "[NETWORK RESTORED] $HOST"
