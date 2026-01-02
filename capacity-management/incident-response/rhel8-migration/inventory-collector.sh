pre-migration-assessment/
    -> inventory-collector.sh
    ->
#!/usr/bin/env bash
# Capability: Collect OS, kernel, package, and service inventory for RHEL7 → RHEL8 migration.

set -euo pipefail

HOSTS_FILE="${1:-hosts.txt}"

collect_inventory() {
    local host="$1"
    echo "=== Inventory for $host ==="
    ssh "$host" "hostnamectl"
    ssh "$host" "rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n'"
    ssh "$host" "systemctl list-units --type=service --state=running"
    echo ""
}

while read -r host; do
    [ -z "$host" ] && continue
    collect_inventory "$host"
done < "$HOSTS_FILE"
