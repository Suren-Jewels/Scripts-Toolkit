#!/usr/bin/env python3
# Capability: Estimate impact radius for failed migrations.

import json
import os

logfile = "history/migration-history.json"

if not os.path.isfile(logfile):
    print("No migration history found.")
    raise SystemExit(0)

with open(logfile) as f:
    history = json.load(f)

failed_hosts = [e["host"] for e in history if e.get("status") == "failed"]
unique_failed = set(failed_hosts)

impact = {
    "failed_hosts": list(unique_failed),
    "failure_count": len(failed_hosts),
    "unique_failure_hosts": len(unique_failed)
}

print(json.dumps(impact, indent=2))
