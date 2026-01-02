severity-detection/
    -> severity-classifier.py
    ->
#!/usr/bin/env python3
"""
Capability: Classify incident severity (SEV1/SEV2/SEV3/None)
based on event payload metrics.
"""

import json
import os
import sys

EVENT_FILE = os.environ.get("EVENT_FILE", "event.json")

if not os.path.isfile(EVENT_FILE):
    raise SystemExit(f"EVENT_FILE not found: {EVENT_FILE}")

with open(EVENT_FILE) as f:
    event = json.load(f)

error_rate = event.get("error_rate", 0)
latency = event.get("latency_ms", 0)
uptime = event.get("uptime", 100)

if event.get("sev1_flag") is True:
    print("SEV1")
    sys.exit(0)

if error_rate >= 20 or latency >= 2000 or uptime < 95:
    print("SEV1")
    sys.exit(0)

if event.get("sev2_flag") is True:
    print("SEV2")
    sys.exit(0)

if error_rate >= 10 or latency >= 1200 or uptime < 97:
    print("SEV2")
    sys.exit(0)

if event.get("sev3_flag") is True:
    print("SEV3")
    sys.exit(0)

if error_rate >= 5 or latency >= 800 or uptime < 99:
    print("SEV3")
    sys.exit(0)

print("NO-SEVERITY")
sys.exit(0)
