migration-incident-detection/
    -> detect-boot-failure.sh
    ->
#!/usr/bin/env bash
# Capability: Detect kernel/bootloader issues post‑migration.

set -euo pipefail

HOSTS_FILE="${1:-hosts.txt}"

check_boot() {
    local host="$1"
    echo "=== Checking boot status on $host ==="

    ssh "$host" "sudo journalctl -b -1 -p err --no-pager | grep -E 'kernel|grub|panic'" \
        && echo "[BOOT FAILURE] $host" \
        || echo "[OK] $host"
}

while read -r host; do
    [ -z "$host" ] && continue
    check_boot "$host"
done < "$HOSTS_FILE"
