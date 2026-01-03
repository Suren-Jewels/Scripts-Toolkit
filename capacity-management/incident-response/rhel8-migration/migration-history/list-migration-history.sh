#!/usr/bin/env bash
# Capability: List all recorded migration events.

set -euo pipefail

LOGFILE="history/migration-history.json"

if [ ! -f "$LOGFILE" ]; then
    echo "No migration history found."
    exit 0
fi

cat "$LOGFILE"
