#!/usr/bin/env bash
# Capability: Scheduled reserve pool audit.
# Executes core reserve-pool scripts and stores results in timestamped directories.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

BASE_DIR="${BASE_DIR:-runs}"
TS=$(date +"%Y%m%d-%H%M%S")
RUN_DIR="$BASE_DIR/$TS"

mkdir -p "$RUN_DIR"

echo "Starting reserve pool audit: $TS"

# Discover pool
discover-reserve-pool.sh > "$RUN_DIR/discover-reserve-pool.json"

# Capacity report
reserve-pool-capacity.py > "$RUN_DIR/reserve-pool-capacity.json"

echo "Reserve pool audit completed: $RUN_DIR"
