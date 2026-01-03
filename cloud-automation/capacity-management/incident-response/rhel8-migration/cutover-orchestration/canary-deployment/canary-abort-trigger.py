#!/usr/bin/env python3
# Capability: Auto-abort rollout if canary failures exceed threshold.

import sys
import json

if len(sys.argv) < 3:
    raise SystemExit("Usage: canary-abort-trigger.py <results.json> <threshold_percent>")

results_file = sys.argv[1]
threshold = int(sys.argv[2])

with open(results_file) as f:
    data = json.load(f)

total = len(data.get("hosts", []))
failed = len([h for h in data.get("hosts", []) if h.get("status") == "failed"])

failure_rate = (failed / total) * 100 if total > 0 else 0

decision = "ABORT" if failure_rate > threshold else "CONTINUE"

print(json.dumps({
    "total_hosts": total,
    "failed_hosts": failed,
    "failure_rate": failure_rate,
    "decision": decision
}, indent=2))
