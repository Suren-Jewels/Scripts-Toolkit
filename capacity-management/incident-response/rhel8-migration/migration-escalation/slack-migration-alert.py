#!/usr/bin/env python3
"""
Capability: Send migration alerts to Slack.
Inputs:
    severity (BLOCKER/MAJOR/MINOR)
"""

import os
import sys
import json
import urllib.request

if len(sys.argv) < 2:
    raise SystemExit("Usage: slack-migration-alert.py <severity>")

severity = sys.argv[1]
webhook = os.getenv("SLACK_WEBHOOK_URL")

if not webhook:
    raise SystemExit("SLACK_WEBHOOK_URL not set")

payload = {
    "text": f"RHEL8 Migration Alert — Severity: {severity}"
}

req = urllib.request.Request(
    webhook,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"}
)

urllib.request.urlopen(req)
print("Slack alert sent.")
