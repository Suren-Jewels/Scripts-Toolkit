#!/usr/bin/env bash
# Capability: Archive reserve-pool audit runs.
# Compresses run directories into timestamped tar.gz archives.
# Optional retention policy via RETAIN_COUNT.

set -euo pipefail

: "${RUNS_DIR:=runs}"

ARCHIVE_DIR="${ARCHIVE_DIR:-archives}"
RETAIN_COUNT="${RETAIN_COUNT:-5}"

mkdir -p "$ARCHIVE_DIR"

# Identify latest run
LATEST_RUN=$(ls -1 "$RUNS_DIR" | sort | tail -n 1)
[ -z "$LATEST_RUN" ] && { echo "No runs found."; exit 0; }

TS=$(date +"%Y%m%d-%H%M%S")
ARCHIVE_NAME="reserve-pool-$TS.tar.gz"

tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$RUNS_DIR" "$LATEST_RUN"

echo "Archived: $ARCHIVE_DIR/$ARCHIVE_NAME"

# Retention cleanup
COUNT=$(ls -1 "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null | wc -l || true)

if [ "$COUNT" -gt "$RETAIN_COUNT" ]; then
    ls -1 "$ARCHIVE_DIR"/*.tar.gz | sort | head -n "$((COUNT - RETAIN_COUNT))" | xargs rm -f
fi
