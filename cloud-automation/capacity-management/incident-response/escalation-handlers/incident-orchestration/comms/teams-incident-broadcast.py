incident-orchestration/comms/
    -> teams-incident-broadcast.py
    ->
#!/usr/bin/env python3
"""
Capability: Broadcast incident updates to Microsoft Teams channels.
Inputs:
    EVENT_FILE     - JSON event payload
    TEAMS_WEBHOOK  - Teams webhook URL
    SEVERITY       - CRITICAL | MAJOR | MODERATE
    MESSAGE        - Optional custom message
"""

import json
import os
import sys
import urllib.request

EVENT_FILE = os.environ.get("EVENT_FILE", "event.json")
TEAMS_WEBHOOK = os.environ.get("TEAMS_WEBHOOK")
SEVERITY = os.environ.get("SEVERITY", "NONE")
MESSAGE = os.environ.get("MESSAGE", "Incident update")

if not TEAMS_WEBHOOK:
    raise SystemExit("TEAMS_WEBHOOK is required.")

if not os.path.isfile(EVENT_FILE):
    raise SystemExit(f"EVENT_FILE not found: {EVENT_FILE}")

with open(EVENT_FILE) as f:
    event = json.load(f)

payload = {
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "summary": MESSAGE,
    "themeColor": "FF0000" if SEVERITY == "CRITICAL" else "FF8C00" if SEVERITY == "MAJOR" else "FFD700",
    "title": f"Incident Update — {SEVERITY}",
    "text": MESSAGE,
    "sections": [
        {
            "facts": [
                {"name": "Severity", "value": SEVERITY},
                {"name": "Event Payload", "value": f"```json\n{json.dumps(event, indent=2)}\n```"}
            ]
        }
    ]
}

req = urllib.request.Request(
    TEAMS_WEBHOOK,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"}
)

with urllib.request.urlopen(req) as resp:
    resp.read()

print(f"Teams broadcast sent for severity: {SEVERITY}")
