#!/usr/bin/env python3
# Capability: Track Mean Time To Resolve (MTTR) migration issues.

import json
import os
from datetime import datetime

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

durations = []

for e in history:
    if e.get("status") != "resolved":
        continue
    start = e.get("start_time")
    end = e.get("end_time")
    if not start or not end:
        continue
    s = datetime.fromisoformat(start)
    e2 = datetime.fromisoformat(end)
    durations.append((e2 - s).total_seconds())

mttr = sum(durations) / len(durations) if durations else 0

print(json.dumps({"mttr_seconds": mttr}, indent=2))
