#!/usr/bin/env python3
"""
Capability: Extract POD allocations (primary DC only) from shared and private pools.
This script does not allocate capacity. It derives POD-specific
allocations from:
- shared allocations
- private allocations
"""

import os
import json
import sys

SHARED_FILE = os.environ.get("SHARED_ALLOC")
PRIVATE_FILE = os.environ.get("PRIVATE_ALLOC")

if not SHARED_FILE:
    raise SystemExit("SHARED_ALLOC is required.")
if not PRIVATE_FILE:
    raise SystemExit("PRIVATE_ALLOC is required.")

with open(SHARED_FILE) as f:
    shared = json.load(f)

with open(PRIVATE_FILE) as f:
    private = json.load(f)

output = {
    "pod_allocations": {
        "shared": {},
        "private": {}
    }
}

# Extract POD from shared pool
for dc, entries in shared["shared_allocations"].items():
    for name, values in entries.items():
        # Primary PODs only (exclude pair-PODs)
        if "-pair" in name:
            continue
        if name.startswith("POD") or name.lower().startswith("pod"):
            output["pod_allocations"]["shared"].setdefault(dc, {})
            output["pod_allocations"]["shared"][dc][name] = values

# Extract POD from private pools
for customer, pools in private["private_allocations"].items():
    output["pod_allocations"]["private"].setdefault(customer, {})

    for dc, entries in pools.items():
        for name, values in entries.items():
            if "-pair" in name:
                continue
            if name.startswith("POD") or name.lower().startswith("pod"):
                output["pod_allocations"]["private"][customer].setdefault(dc, {})
                output["pod_allocations"]["private"][customer][dc][name] = values

print(json.dumps(output, indent=2))
