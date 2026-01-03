migration-history/
    -> prune-migration-history.sh
    ->
#!/usr/bin/env bash
# Capability: Retention-based cleanup of migration history.

set -euo pipefail

DAYS="${1:?Usage: prune-migration-history.sh <days>}"
LOGFILE="history/migration-history.json"

if [ ! -f "$LOGFILE" ]; then
    echo "No migration history found."
    exit 0
fi

TMPFILE=$(mktemp)

python3 - <<EOF > "$TMPFILE"
import json, time

days = int("$DAYS")
cutoff = time.time() - (days * 86400)

with open("$LOGFILE") as f:
    history = json.load(f)

filtered = []
for event in history:
    ts = event.get("timestamp")
    if not ts:
        continue
    try:
        t = time.mktime(time.strptime(ts.split(".")[0], "%Y-%m-%dT%H:%M:%S"))
        if t >= cutoff:
            filtered.append(event)
    except:
        continue

print(json.dumps(filtered, indent=2))
EOF

mv "$TMPFILE" "$LOGFILE"
echo "Migration history pruned to last $DAYS days."
