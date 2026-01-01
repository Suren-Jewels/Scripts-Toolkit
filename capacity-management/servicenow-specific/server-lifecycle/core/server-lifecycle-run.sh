#!/usr/bin/env bash
# Capability: Scheduled server lifecycle audit.
# Executes core lifecycle scripts and stores results in timestamped directories.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

BASE_DIR="${BASE_DIR:-runs}"
TS=$(date +"%Y%m%d-%H%M%S")
RUN_DIR="$BASE_DIR/$TS"

mkdir -p "$RUN_DIR"

echo "Starting server lifecycle audit: $TS"

# Discover servers
server-discover.sh > "$RUN_DIR/server-discover.json"

# Health report
server-health.py > "$RUN_DIR/server-health.json"

# Optional baseline configuration
if [[ -n "${CONFIG_CMD:-}" ]]; then
    echo "Applying baseline configuration..."
    while read -r name; do
        NODE_NAME="$name" CONFIG_CMD="$CONFIG_CMD" server-configure.sh
    done < <(jq -r '.[].name' "$RUN_DIR/server-discover.json")
fi

echo "Server lifecycle audit completed: $RUN_DIR"
