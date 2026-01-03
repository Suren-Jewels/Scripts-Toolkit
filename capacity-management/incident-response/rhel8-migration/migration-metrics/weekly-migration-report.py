#!/usr/bin/env python3
# Capability: Auto-generate weekly migration reports for stakeholders.

import json
import os
from datetime import datetime, timedelta

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

cutoff = datetime.utcnow() - timedelta(days=7)

weekly = [e for e in history if datetime.fromisoformat(e["timestamp"]) >= cutoff]

report = {
    "generated_at": datetime.utcnow().isoformat(),
    "total_events": len(weekly),
    "success": len([e for e in weekly if e.get("status") == "success"]),
    "failed": len([e for e in weekly if e.get("status") == "failed"]),
    "raw": weekly
}

with open("metrics/weekly-report.json", "w") as f:
    json.dump(report, f, indent=2)

print("Weekly migration report generated: metrics/weekly-report.json")
