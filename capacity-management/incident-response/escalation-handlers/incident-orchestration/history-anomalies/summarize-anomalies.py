incident-orchestration/history-anomalies/
    -> summarize-anomalies.py
    ->
#!/usr/bin/env python3
"""
Capability: Summarize anomaly patterns across incident history.
Logic:
    - Load anomaly scores
    - Identify highest scoring snapshots
    - Identify severity distribution
"""

import json
import os

HISTORY_DIR = "incident-orchestration/history"

if not os.path.isdir(HISTORY_DIR):
    raise SystemExit("No history directory found.")

# Load anomaly scores by invoking anomaly-score.py
from subprocess import check_output

raw = check_output(["python3", "incident-orchestration/history-anomalies/anomaly-score.py"])
scores = json.loads(raw)

# Highest scoring snapshots
max_score = max(item["score"] for item in scores)
top = [item for item in scores if item["score"] == max_score]

# Severity distribution
dist = {}
for item in scores:
    sev = item["severity"]
    dist[sev] = dist.get(sev, 0) + 1

summary = {
    "highest_score": max_score,
    "top_snapshots": top,
    "severity_distribution": dist
}

print(json.dumps(summary, indent=2))
