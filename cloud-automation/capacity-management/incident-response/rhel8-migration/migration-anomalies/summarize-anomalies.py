#!/usr/bin/env python3
# Capability: Summaries of migration anomaly patterns.

import json
import os
from collections import Counter

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

hosts = [e["host"] for e in history]
statuses = [e["status"] for e in history]

summary = {
    "total_events": len(history),
    "unique_hosts": len(set(hosts)),
    "status_counts": dict(Counter(statuses)),
    "top_failure_hosts": dict(Counter([e["host"] for e in history if e["status"] == "failed"]).most_common(5))
}

print(json.dumps(summary, indent=2))
