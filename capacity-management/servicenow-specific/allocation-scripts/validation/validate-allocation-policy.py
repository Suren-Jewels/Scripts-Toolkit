#!/usr/bin/env python3
"""
Capability: Validate allocation policy compliance.
Checks:
- domain ratios
- customer rules
- DC placement rules
- POD/Pair-POD policy constraints
"""

import os
import json
import sys

ALLOC_FILE = os.environ.get("ALLOCATION_FILE")
if not ALLOC_FILE:
    raise SystemExit("ALLOCATION_FILE is required.")

with open(ALLOC_FILE) as f:
    alloc = json.load(f)

discovered = alloc["discovered"]
shared = alloc["shared"]["shared_allocations"]
private = alloc["private"]["private_allocations"]
pods = discovered["pods"]

errors = []

# Example policy: POD and Pair-POD must be in different DCs
for pod_name, cfg in pods.items():
    if cfg["dc"] == cfg["pair_dc"]:
        errors.append(f"POD {pod_name} violates DC separation policy.")

# Example policy: no domain may exceed 70% of shared pool CPU in any DC
for dc in discovered["data_centers"]:
    cap_cpu = discovered["shared_pool"][dc]["cpu"]
    limit = cap_cpu * 0.7

    for name, v in shared.get(dc, {}).items():
        if v["cpu"] > limit:
            errors.append(f"{name} exceeds 70% CPU policy in {dc}.")

# Example policy: customers must not exceed 50% of any DC's private pool
for customer, pools in private.items():
    for dc in discovered["data_centers"]:
        cap_cpu = discovered["private_pools"][customer][dc]["cpu"]
        limit = cap_cpu * 0.5

        used_cpu = sum(v["cpu"] for v in pools.get(dc, {}).values())

        if used_cpu > limit:
            errors.append(f"{customer} exceeds 50% private CPU policy in {dc}.")

if errors:
    print(json.dumps({"status": "failed", "errors": errors}, indent=2))
    sys.exit(1)

print(json.dumps({"status": "ok"}, indent=2))
