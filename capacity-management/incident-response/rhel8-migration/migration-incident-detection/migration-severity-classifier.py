migration-incident-detection/
    -> migration-severity-classifier.py
    ->
#!/usr/bin/env python3
"""
Capability: Classify migration issues into:
    - BLOCKER (boot failure, kernel panic, missing root FS)
    - MAJOR   (service failures, network regressions)
    - MINOR   (warnings, deprecated configs)
"""

import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: migration-severity-classifier.py <incident.json>")

incident_file = sys.argv[1]

with open(incident_file) as f:
    data = json.load(f)

severity = "MINOR"

if data.get("boot_failure"):
    severity = "BLOCKER"
elif data.get("service_failures") or data.get("network_issues"):
    severity = "MAJOR"

print(json.dumps({"severity": severity}, indent=2))
