#!/usr/bin/env python3
# Capability: Simulate large‑scale migration load across many hosts.

import sys
import time
import json
import random

if len(sys.argv) < 3:
    raise SystemExit("Usage: simulate-migration-load.py <hosts.txt> <concurrency>")

hostfile = sys.argv[1]
concurrency = int(sys.argv[2])

with open(hostfile) as f:
    hosts = [h.strip() for h in f.readlines() if h.strip()]

results = []
active = 0

print("=== Simulating Migration Load ===")

for host in hosts:
    if active >= concurrency:
        time.sleep(0.5)
        active = 0

    status = random.choice(["success", "failed"])
    duration = random.randint(30, 300)

    results.append({
        "host": host,
        "status": status,
        "duration_seconds": duration
    })

    active += 1

with open("metrics/load-test-results.json", "w") as f:
    json.dump(results, f, indent=2)

print("Load test complete → metrics/load-test-results.json")
