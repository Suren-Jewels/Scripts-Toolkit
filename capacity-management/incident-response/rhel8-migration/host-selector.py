Scripts-Toolkit/capacity-management/incident-response/rhel8-migration/
    -> host-selector.py
    ->
#!/usr/bin/env python3
"""
Capability: Select hosts for migration batches.
Modes:
    --canary      Selects 10% of hosts
    --batch N     Selects batches of size N
    --all         Returns all hosts
"""

import sys
import random

if len(sys.argv) < 3:
    raise SystemExit("Usage: host-selector.py <hosts.txt> <--canary|--batch N|--all>")

hostfile = sys.argv[1]
mode = sys.argv[2]

with open(hostfile) as f:
    hosts = [h.strip() for h in f.readlines() if h.strip()]

if mode == "--all":
    for h in hosts:
        print(h)

elif mode == "--canary":
    count = max(1, len(hosts) // 10)
    for h in random.sample(hosts, count):
        print(h)

elif mode == "--batch":
    size = int(sys.argv[3])
    for i in range(0, len(hosts), size):
        print("\n".join(hosts[i:i+size]))
        print("--- batch-end ---")

else:
    raise SystemExit("Invalid mode.")
