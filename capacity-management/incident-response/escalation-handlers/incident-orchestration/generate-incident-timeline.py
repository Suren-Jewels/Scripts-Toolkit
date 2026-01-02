incident-orchestration/
    -> generate-incident-timeline.py
    ->
#!/usr/bin/env python3
"""
Capability: Generate a human-readable incident timeline.
Reads:
    - history snapshots
Outputs:
    - Ordered timeline of severity + timestamps
"""

import os
import json

HISTORY_DIR = "escalation-handlers/incident-orchestration/history"

if not os.path.isdir(HISTORY_DIR):
    raise SystemExit("No history directory found.")

files = sorted(os.listdir(HISTORY_DIR))

timeline = []

for f in files:
    path = os.path.join(HISTORY_DIR, f)
    with open(path) as snap:
        data = json.load(snap)
        timeline.append({
            "timestamp": data.get("timestamp"),
            "severity": data.get("severity")
        })

for entry in timeline:
    print(f"{entry['timestamp']} — {entry['severity']}")
