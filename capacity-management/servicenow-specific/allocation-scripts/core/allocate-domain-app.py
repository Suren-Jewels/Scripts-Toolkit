#!/usr/bin/env python3
"""
Capability: Extract APP allocations from shared and private pools.
This script does not allocate capacity. It derives APP-specific
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
    "app_allocations": {
        "shared": {},
        "private": {}
    }
}

# Extract APP from shared pool
for dc, entries in shared["shared_allocations"].items():
    if "app" in entries:
        output["app_allocations"]["shared"].setdefault(dc, {})
        output["app_allocations"]["shared"][dc] = entries["app"]

# Extract APP from private pools
for customer, pools in private["private_allocations"].items():
    output["app_allocations"]["private"].setdefault(customer, {})

    for dc, entries in pools.items():
        if "app" in entries:
            output["app_allocations"]["private"][customer].setdefault(dc, {})
            output["app_allocations"]["private"][customer][dc] = entries["app"]

print(json.dumps(output, indent=2))
