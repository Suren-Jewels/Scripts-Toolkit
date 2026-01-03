#!/usr/bin/env python3
"""
Capability: Auto-escalate migration incidents based on severity + time threshold.
Reads:
    - escalation-policy.json
Inputs:
    severity
    minutes_elapsed
"""

import json
import sys

if len(sys.argv) < 3:
    raise SystemExit("Usage: auto-escalation-trigger.py <severity> <minutes_elapsed>")

severity = sys.argv[1]
minutes = int(sys.argv[2])

with open("escalation-policy.json") as f:
    policy = json.load(f)

threshold = policy[severity]["auto_escalate_after_minutes"]

if minutes >= threshold:
    print("AUTO_ESCALATE")
else:
    print("NO_ACTION")
