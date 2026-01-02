incident-orchestration/history/
    -> list-history.sh
    ->
#!/usr/bin/env bash
# Capability: List all recorded incident history snapshots.

set -euo pipefail

HISTORY_DIR="incident-orchestration/history"

if [ ! -d "$HISTORY_DIR" ]; then
    echo "No history directory found."
    exit 0
fi

echo "Incident History Snapshots:"
ls -1 "$HISTORY_DIR"
