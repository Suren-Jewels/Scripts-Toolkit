incident-orchestration/history-anomalies/
    -> detect-anomaly-trends.py
    ->
#!/usr/bin/env python3
"""
Capability: Detect anomaly trends in historical incident data.
Logic:
    - Load all snapshots
    - Count severity occurrences
    - Detect spikes or drops vs rolling average
Outputs:
    Prints anomaly summary
"""

import os
import json
from statistics import mean

HISTORY_DIR = "incident-orchestration/history"

if not os.path.isdir(HISTORY_DIR):
    raise SystemExit("No history directory found.")

files = sorted(os.listdir(HISTORY_DIR))
if not files:
    raise SystemExit("No history snapshots found.")

severities = []

for f in files:
    path = os.path.join(HISTORY_DIR, f)
    with open(path) as snapshot:
        data = json.load(snapshot)
        severities.append(data.get("severity", "NONE"))

# Count occurrences
counts = {
    "CRITICAL": severities.count("CRITICAL"),
    "MAJOR": severities.count("MAJOR"),
    "MODERATE": severities.count("MODERATE"),
    "NONE": severities.count("NONE")
}

# Simple anomaly detection: compare each severity count to mean
values = list(counts.values())
avg = mean(values)

anomalies = {k: v for k, v in counts.items() if v > avg * 1.5 or v < avg * 0.5}

print("Severity Counts:", counts)
print("Detected Anomalies:", anomalies if anomalies else "None")
