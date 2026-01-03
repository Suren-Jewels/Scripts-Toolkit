#!/usr/bin/env python3
# Capability: Assign anomaly score to migration events.

import json
import sys
import os

if len(sys.argv) < 2:
    raise SystemExit("Usage: anomaly-score.py <host>")

host = sys.argv[1]
logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

events = [e for e in history if e.get("host") == host]

score = 0
for e in events:
    if e.get("status") == "failed":
        score += 10
    if e.get("status") == "success":
        score -= 5

if score < 0:
    score = 0

print(json.dumps({"host": host, "anomaly_score": score}, indent=2))
