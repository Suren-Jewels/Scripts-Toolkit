#!/usr/bin/env bash
# Capability: ASCII heatmap of migration anomalies.

set -euo pipefail

LOGFILE="history/migration-history.json"

if [ ! -f "$LOGFILE" ]; then
    echo "No migration history found."
    exit 0
fi

python3 - <<'EOF'
import json
from collections import Counter

with open("history/migration-history.json") as f:
    history = json.load(f)

fails = [e["host"] for e in history if e.get("status") == "failed"]
counts = Counter(fails)

for host, count in counts.items():
    bar = "#" * count
    print(f"{host:20} | {bar}")
EOF
