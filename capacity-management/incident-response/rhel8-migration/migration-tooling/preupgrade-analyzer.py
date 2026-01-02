migration-tooling/
    -> preupgrade-analyzer.py
    ->
#!/usr/bin/env python3
"""
Capability: Parse LEAPP preupgrade reports and extract blockers, inhibitors, and warnings.
"""

import json
import sys
import os

if len(sys.argv) < 2:
    raise SystemExit("Usage: preupgrade-analyzer.py <report.json>")

report_file = sys.argv[1]

if not os.path.isfile(report_file):
    raise SystemExit(f"Report not found: {report_file}")

with open(report_file) as f:
    data = json.load(f)

summary = {
    "blockers": [],
    "inhibitors": [],
    "warnings": []
}

for entry in data.get("entries", []):
    severity = entry.get("severity")
    message = entry.get("title")

    if severity == "error":
        summary["blockers"].append(message)
    elif severity == "inhibitor":
        summary["inhibitors"].append(message)
    elif severity == "warning":
        summary["warnings"].append(message)

print(json.dumps(summary, indent=2))
