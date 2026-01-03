#!/usr/bin/env python3
# Capability: Calculate % successful migrations (daily/weekly/monthly).

import json
import sys
import os
from datetime import datetime, timedelta

if len(sys.argv) < 2:
    raise SystemExit("Usage: success-rate-calculator.py <days>")

days = int(sys.argv[1])
cutoff = datetime.utcnow() - timedelta(days=days)

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

filtered = []
for e in history:
    ts = e.get("timestamp")
    if not ts:
        continue
    t = datetime.fromisoformat(ts)
    if t >= cutoff:
        filtered.append(e)

total = len(filtered)
success = len([e for e in filtered if e.get("status") == "success"])

rate = (success / total * 100) if total > 0 else 0

print(json.dumps({
    "days": days,
    "total_events": total,
    "success_rate_percent": rate
}, indent=2))
