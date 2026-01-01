#!/usr/bin/env python3
"""
Capability: Send server lifecycle notifications to Slack or Teams.
Requires one of:
- SLACK_WEBHOOK
- TEAMS_WEBHOOK

Environment:
- RUN_DIR: directory containing the latest lifecycle audit results
"""

import os
import json
import urllib.request

RUN_DIR = os.environ.get("RUN_DIR")
if not RUN_DIR:
    raise SystemExit("RUN_DIR is required.")

SLACK = os.environ.get("SLACK_WEBHOOK")
TEAMS = os.environ.get("TEAMS_WEBHOOK")

if not SLACK and not TEAMS:
    raise SystemExit("SLACK_WEBHOOK or TEAMS_WEBHOOK is required.")

def send_webhook(url, payload):
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    urllib.request.urlopen(req)

summary = {
    "run_directory": RUN_DIR,
    "message": "Server lifecycle audit completed successfully."
}

if SLACK:
    send_webhook(SLACK, {"text": json.dumps(summary, indent=2)})

if TEAMS:
    send_webhook(TEAMS, {"text": json.dumps(summary, indent=2)})

print("Notification sent.")
