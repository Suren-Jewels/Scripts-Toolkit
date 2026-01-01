#!/usr/bin/env bash
# Capability: Archive allocation run directories with retention.
# Compresses completed run folders into tar.gz archives and
# enforces retention policy.

set -euo pipefail

: "${RUNS_DIR:=runs}"
: "${ARCHIVE_DIR:=archive}"
: "${RETENTION:=30}"

mkdir -p "$ARCHIVE_DIR"

# Archive each run directory
for dir in "$RUNS_DIR"/*; do
    [ -d "$dir" ] || continue

    name=$(basename "$dir")
    archive="$ARCHIVE_DIR/$name.tar.gz"

    # Skip if already archived
    if [ -f "$archive" ]; then
        continue
    fi

    tar -czf "$archive" -C "$RUNS_DIR" "$name"
done

# Enforce retention
count=$(ls -1 "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null | wc -l || true)

if [ "$count" -gt "$RETENTION" ]; then
    excess=$((count - RETENTION))
    ls -1t "$ARCHIVE_DIR"/*.tar.gz | tail -n "$excess" | xargs rm -f
fi
