migration-tooling/
    -> migration-executor.sh
    ->
#!/usr/bin/env bash
# Capability: Executes controlled migration steps after LEAPP preupgrade validation.

set -euo pipefail

HOSTS_FILE="${1:-hosts.txt}"

execute_migration() {
    local host="$1"
    echo "=== Executing migration steps on $host ==="

    ssh "$host" "sudo dnf clean all"
    ssh "$host" "sudo dnf distro-sync -y"
    ssh "$host" "sudo systemctl daemon-reload"
    ssh "$host" "sudo reboot"
}

while read -r host; do
    [ -z "$host" ] && continue
    execute_migration "$host"
done < "$HOSTS_FILE"
