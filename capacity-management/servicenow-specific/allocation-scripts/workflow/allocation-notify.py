#!/usr/bin/env python3
"""
Capability: Send allocation summary notification to Slack or Teams.
Reads allocation.json and posts a minimal JSON summary.
"""

import os
import json
import sys
import urllib.request

ALLOCATION_FILE = os.environ.get("ALLOCATION_FILE")
if not ALLOCATION_FILE:
    raise SystemExit("ALLOCATION_FILE is required.")

SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK")
TEAMS_WEBHOOK = os.environ.get("TEAMS_WEBHOOK")

if not SLACK_WEBHOOK and not TEAMS_WEBHOOK:
    raise SystemExit("SLACK_WEBHOOK or TEAMS_WEBHOOK is required.")

with open(ALLOCATION_FILE) as f:
    data = json.load(f)

summary = {
    "timestamp": data.get("timestamp"),
    "domains": list(data.get("domains", {}).keys()),
    "shared_keys": list(data.get("shared", {}).keys()),
    "private_keys": list(data.get("private", {}).keys())
}

payload = json.dumps({"text": json.dumps(summary, indent=2)}).encode("utf-8")

def post(url):
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    urllib.request.urlopen(req)

if SLACK_WEBHOOK:
    post(SLACK_WEBHOOK)

if TEAMS_WEBHOOK:
    post(TEAMS_WEBHOOK)
