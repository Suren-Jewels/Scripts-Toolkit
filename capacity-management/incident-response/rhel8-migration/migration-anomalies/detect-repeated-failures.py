#!/usr/bin/env python3
# Capability: Detect hosts repeatedly failing migration attempts.

import json
import sys
import os
from collections import Counter

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

failures = [e["host"] for e in history if e.get("status") == "failed"]
counts = Counter(failures)

repeated = {host: count for host, count in counts.items() if count > 1}

print(json.dumps({"repeated_failures": repeated}, indent=2))
