#!/usr/bin/env python3
# Capability: Track 99.9% service continuity commitment.

import json
import os

logfile = "metrics/uptime.json"

if not os.path.isfile(logfile):
    print("No uptime metrics found.")
    raise SystemExit(0)

with open(logfile) as f:
    data = json.load(f)

uptime = data.get("uptime_percent", 0)
sla = 99.9
compliant = uptime >= sla

print(json.dumps({
    "uptime_percent": uptime,
    "sla_target": sla,
    "compliant": compliant
}, indent=2))
