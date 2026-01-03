#!/usr/bin/env python3
# Capability: Select canary hosts for phased rollout (10 → 100 → all).

import sys
import json

if len(sys.argv) < 3:
    raise SystemExit("Usage: canary-selector.py <hosts.txt> <phase>")

hostfile = sys.argv[1]
phase = sys.argv[2]  # "10", "100", or "all"

with open(hostfile) as f:
    hosts = [h.strip() for h in f.readlines() if h.strip()]

if phase == "10":
    selected = hosts[:10]
elif phase == "100":
    selected = hosts[:100]
elif phase == "all":
    selected = hosts
else:
    raise SystemExit("Phase must be: 10 | 100 | all")

print(json.dumps({"phase": phase, "selected_hosts": selected}, indent=2))
