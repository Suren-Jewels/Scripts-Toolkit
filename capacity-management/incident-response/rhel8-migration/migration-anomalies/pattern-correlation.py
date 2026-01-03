#!/usr/bin/env python3
# Capability: Correlate failure patterns across hosts.

import json
import os
from collections import defaultdict

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

patterns = defaultdict(list)

for event in history:
    host = event.get("host")
    status = event.get("status")
    patterns[status].append(host)

correlation = {
    "failed_hosts": list(set(patterns.get("failed", []))),
    "success_hosts": list(set(patterns.get("success", []))),
    "failure_overlap": len(set(patterns.get("failed", [])) & set(patterns.get("success", [])))
}

print(json.dumps(correlation, indent=2))
