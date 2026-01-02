incident-orchestration/comms/
    -> slack-incident-broadcast.py
    ->
#!/usr/bin/env python3
"""
Capability: Broadcast incident updates to Slack channels.
Inputs:
    EVENT_FILE     - JSON event payload
    SLACK_WEBHOOK  - Slack webhook URL
    SEVERITY       - CRITICAL | MAJOR | MODERATE
    MESSAGE        - Optional custom message
"""

import json
import os
import sys
import urllib.request

EVENT_FILE = os.environ.get("EVENT_FILE", "event.json")
SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK")
SEVERITY = os.environ.get("SEVERITY", "NONE")
MESSAGE = os.environ.get("MESSAGE", "Incident update")

if not SLACK_WEBHOOK:
    raise SystemExit("SLACK_WEBHOOK is required.")

if not os.path.isfile(EVENT_FILE):
    raise SystemExit(f"EVENT_FILE not found: {EVENT_FILE}")

with open(EVENT_FILE) as f:
    event = json.load(f)

color_map = {
    "CRITICAL": "#ff0000",
    "MAJOR": "#ff8c00",
    "MODERATE": "#ffd700",
    "NONE": "#cccccc"
}

payload = {
    "text": f"📣 *{MESSAGE}*",
    "attachments": [
        {
            "color": color_map.get(SEVERITY, "#cccccc"),
            "fields": [
                {"title": "Severity", "value": SEVERITY, "short": True},
                {"title": "Event Payload", "value": json.dumps(event, indent=2), "short": False}
            ]
        }
    ]
}

req = urllib.request.Request(
    SLACK_WEBHOOK,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"}
)

with urllib.request.urlopen(req) as resp:
    resp.read()

print(f"Slack broadcast sent for severity: {SEVERITY}")
