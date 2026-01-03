#!/usr/bin/env python3
# Capability: Retrieve the latest migration event.

import json
import os

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

if not history:
    print("History file is empty.")
    raise SystemExit(0)

print(json.dumps(history[-1], indent=2))
