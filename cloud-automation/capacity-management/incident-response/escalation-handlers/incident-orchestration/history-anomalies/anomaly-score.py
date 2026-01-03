incident-orchestration/history-anomalies/
    -> anomaly-score.py
    ->
#!/usr/bin/env python3
"""
Capability: Assign anomaly scores to incident snapshots.
Logic:
    - Score based on severity weight
    - CRITICAL = 3, MAJOR = 2, MODERATE = 1, NONE = 0
    - Output per-snapshot score list
"""

import os
import json

HISTORY_DIR = "incident-orchestration/history"

weights = {
    "CRITICAL": 3,
    "MAJOR": 2,
    "MODERATE": 1,
    "NONE": 0
}

if not os.path.isdir(HISTORY_DIR):
    raise SystemExit("No history directory found.")

files = sorted(os.listdir(HISTORY_DIR))
if not files:
    raise SystemExit("No history snapshots found.")

scores = []

for f in files:
    path = os.path.join(HISTORY_DIR, f)
    with open(path) as snapshot:
        data = json.load(snapshot)
        sev = data.get("severity", "NONE")
        score = weights.get(sev, 0)
        scores.append({"file": f, "severity": sev, "score": score})

print(json.dumps(scores, indent=2))
