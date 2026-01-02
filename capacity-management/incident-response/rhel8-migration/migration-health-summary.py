Scripts-Toolkit/capacity-management/incident-response/rhel8-migration/
    -> migration-health-summary.py
    ->
#!/usr/bin/env python3
"""
Capability: Summarize migration health across all hosts.
Reads:
    - migration-history records
    - anomaly scores
Outputs:
    - health summary (OK / WARN / FAIL)
"""

import json
import os

HIST_DIR = "migration-history"

if not os.path.isdir(HIST_DIR):
    raise SystemExit("No migration history found.")

files = sorted(os.listdir(HIST_DIR))
events = []

for f in files:
    path = os.path.join(HIST_DIR, f)
    with open(path) as snap:
        events.append(json.load(snap))

blockers = [e for e in events if e.get("severity") == "BLOCKER"]
majors = [e for e in events if e.get("severity") == "MAJOR"]

summary = {
    "total_events": len(events),
    "blockers": len(blockers),
    "majors": len(majors),
    "overall_health": "FAIL" if blockers else ("WARN" if majors else "OK")
}

print(json.dumps(summary, indent=2))
