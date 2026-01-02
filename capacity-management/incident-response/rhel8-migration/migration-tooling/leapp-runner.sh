migration-tooling/
    -> leapp-runner.sh
    ->
#!/usr/bin/env bash
# Capability: Wrapper for LEAPP migration automation.

set -euo pipefail

HOSTS_FILE="${1:-hosts.txt}"

run_leapp() {
    local host="$1"
    echo "=== Running LEAPP on $host ==="
    ssh "$host" "sudo leapp preupgrade --verbose"
    ssh "$host" "sudo leapp upgrade --verbose"
}

while read -r host; do
    [ -z "$host" ] && continue
    run_leapp "$host"
done < "$HOSTS_FILE"
