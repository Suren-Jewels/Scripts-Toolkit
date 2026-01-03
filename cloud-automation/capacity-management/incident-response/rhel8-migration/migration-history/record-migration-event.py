#!/usr/bin/env python3
# Capability: Record each migration attempt into a persistent history log.

import json
import sys
import os
from datetime import datetime

if len(sys.argv) < 3:
    raise SystemExit("Usage: record-migration-event.py <host> <status>")

host = sys.argv[1]
status = sys.argv[2]

event = {
    "host": host,
    "status": status,
    "timestamp": datetime.utcnow().isoformat()
}

os.makedirs("history", exist_ok=True)
logfile = "history/migration-history.json"

history = []
if os.path.isfile(logfile):
    with open(logfile) as f:
        history = json.load(f)

history.append(event)

with open(logfile, "w") as f:
    json.dump(history, f, indent=2)

print("Migration event recorded.")
