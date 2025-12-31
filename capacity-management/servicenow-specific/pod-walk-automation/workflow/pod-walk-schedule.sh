#!/usr/bin/env bash
# Capability: Scheduled pod walk runner.
# Executes core pod-walk scripts on a timed or manual schedule.
# Output structure:
# runs/<timestamp>/

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"

BASE_DIR="${BASE_DIR:-runs}"
TS=$(date +"%Y%m%d-%H%M%S")
RUN_DIR="$BASE_DIR/$TS"

mkdir -p "$RUN_DIR"

echo "Starting pod walk: $TS"

# Basic walk
pod-walk-basic.sh > "$RUN_DIR/pod-walk-basic.json"

# Detailed walk
pod-walk-detailed.py > "$RUN_DIR/pod-walk-detailed.json"

# Logs
OUTPUT_DIR="$RUN_DIR/logs" pod-logs-collect.sh

# Events
OUTPUT_DIR="$RUN_DIR/events" pod-events-collect.sh

# Restart report
pod-restart-report.py > "$RUN_DIR/pod-restart-report.json"

# Resource report
pod-resource-report.py > "$RUN_DIR/pod-resource-report.json"

echo "Pod walk completed: $RUN_DIR"
