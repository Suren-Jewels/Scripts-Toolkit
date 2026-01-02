incident-orchestration/history/
    -> record-incident-history.py
    ->
#!/usr/bin/env python3
"""
Capability: Record a timestamped snapshot of an incident event.
Outputs:
    history/<timestamp>.json
Inputs:
    EVENT_FILE  - JSON event payload
    SEVERITY    - CRITICAL | MAJOR | MODERATE | NONE
"""

import json
import os
import sys
from datetime import datetime

EVENT_FILE = os.environ.get("EVENT_FILE", "event.json")
SEVERITY = os.environ.get("SEVERITY", "NONE")
HISTORY_DIR = "incident-orchestration/history"

if not os.path.isfile(EVENT_FILE):
    raise SystemExit(f"EVENT_FILE not found: {EVENT_FILE}")

os.makedirs(HISTORY_DIR, exist_ok=True)

timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
output_path = os.path.join(HISTORY_DIR, f"{timestamp}.json")

with open(EVENT_FILE) as f:
    event = json.load(f)

record = {
    "timestamp": timestamp,
    "severity": SEVERITY,
    "event": event
}

with open(output_path, "w") as f:
    json.dump(record, f, indent=2)

print(f"Incident history recorded: {output_path}")
