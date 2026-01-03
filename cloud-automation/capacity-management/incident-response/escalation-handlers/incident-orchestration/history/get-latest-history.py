incident-orchestration/history/
    -> get-latest-history.py
    ->
#!/usr/bin/env python3
"""
Capability: Retrieve the most recent incident history snapshot.
Outputs:
    Prints the latest JSON snapshot.
"""

import os
import json

HISTORY_DIR = "incident-orchestration/history"

if not os.path.isdir(HISTORY_DIR):
    raise SystemExit("No history directory found.")

files = sorted(os.listdir(HISTORY_DIR))

if not files:
    raise SystemExit("No history snapshots found.")

latest = files[-1]
path = os.path.join(HISTORY_DIR, latest)

with open(path) as f:
    data = json.load(f)

print(json.dumps(data, indent=2))
