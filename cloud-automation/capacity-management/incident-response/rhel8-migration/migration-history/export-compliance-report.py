#!/usr/bin/env python3
# Capability: Generate a compliance audit report from migration history.

import json
import os
from datetime import datetime

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

report = {
    "generated_at": datetime.utcnow().isoformat(),
    "total_events": len(history),
    "successful": [e for e in history if e.get("status") == "success"],
    "failed": [e for e in history if e.get("status") == "failed"],
    "raw_history": history
}

with open("history/compliance-report.json", "w") as f:
    json.dump(report, f, indent=2)

print("Compliance report generated: history/compliance-report.json")
