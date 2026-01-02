incident-orchestration/history/
    -> prune-history.sh
    ->
#!/usr/bin/env bash
# Capability: Prune old incident history snapshots.
# Inputs:
#   RETENTION - number of snapshots to keep (default: 50)

set -euo pipefail

HISTORY_DIR="incident-orchestration/history"
RETENTION="${RETENTION:-50}"

if [ ! -d "$HISTORY_DIR" ]; then
    echo "No history directory found."
    exit 0
fi

cd "$HISTORY_DIR"

count=$(ls -1 | wc -l)

if [ "$count" -le "$RETENTION" ]; then
    echo "No pruning needed. ($count <= $RETENTION)"
    exit 0
fi

ls -1t | tail -n +"$((RETENTION + 1))" | xargs rm -f

echo "Pruned history. Retention limit: $RETENTION"
