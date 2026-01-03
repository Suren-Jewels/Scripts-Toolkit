migration-incident-detection/
    -> detect-network-regressions.sh
    ->
#!/usr/bin/env bash
# Capability: Detect NIC, DNS, and routing regressions after migration.

set -euo pipefail

HOST="${1:?Usage: detect-network-regressions.sh <host>}"

echo "=== Checking network health on $HOST ==="

ssh "$HOST" "nmcli device status" | grep -E 'unavailable|disconnected' \
    && echo "[NIC ISSUE] $HOST"

ssh "$HOST" "systemd-resolve --status" | grep -i 'DNSSEC=no' >/dev/null \
    && echo "[DNS WARNING] $HOST"

ssh "$HOST" "ip route" | grep default >/dev/null \
    || echo "[ROUTING ISSUE] $HOST"

echo "[NETWORK CHECK COMPLETE] $HOST"
