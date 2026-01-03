oncall-routing/
    -> slack-escalation.py
    ->
#!/usr/bin/env python3
"""
Capability: Send escalation notifications to Slack.
Inputs:
    EVENT_FILE     - JSON event payload
    SLACK_WEBHOOK  - Slack webhook URL
    SEVERITY       - CRITICAL | MAJOR | MODERATE
"""

import json
import os
import sys
import urllib.request

EVENT_FILE = os.environ.get("EVENT_FILE", "event.json")
SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK")
SEVERITY = os.environ.get("SEVERITY", "NONE")

if not SLACK_WEBHOOK:
    raise SystemExit("SLACK_WEBHOOK is required.")

if not os.path.isfile(EVENT_FILE):
    raise SystemExit(f"EVENT_FILE not found: {EVENT_FILE}")

with open(EVENT_FILE) as f:
    event = json.load(f)

message = {
    "text": f"🚨 Escalation triggered: *{SEVERITY}*",
    "attachments": [
        {
            "color": "#ff0000" if SEVERITY == "CRITICAL" else "#ffa500" if SEVERITY == "MAJOR" else "#ffcc00",
            "fields": [
                {"title": "Severity", "value": SEVERITY, "short": True},
                {"title": "Event", "value": json.dumps(event, indent=2), "short": False}
            ]
        }
    ]
}

req = urllib.request.Request(
    SLACK_WEBHOOK,
    data=json.dumps(message).encode("utf-8"),
    headers={"Content-Type": "application/json"}
)

with urllib.request.urlopen(req) as resp:
    resp.read()

print(f"Slack escalation sent for severity: {SEVERITY}")
