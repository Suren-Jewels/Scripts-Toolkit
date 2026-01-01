#!/usr/bin/env python3
"""
Capability: Discover and normalize capacity inputs.
Outputs a unified JSON structure containing:
- data centers
- shared pools
- private customer pools
- domain minimums
- POD and Pair-POD mappings
"""

import os
import json
import sys

CAPACITY_FILE = os.environ.get("CAPACITY_FILE")
if not CAPACITY_FILE:
    raise SystemExit("CAPACITY_FILE is required.")

with open(CAPACITY_FILE) as f:
    raw = json.load(f)

# Required top-level keys
required_keys = [
    "data_centers",
    "shared_pool",
    "private_pools",
    "domains",
    "pods"
]

for key in required_keys:
    if key not in raw:
        raise SystemExit(f"Missing required key: {key}")

# Normalize DC list
dc_list = raw["data_centers"]
if not isinstance(dc_list, list) or len(dc_list) < 2:
    raise SystemExit("data_centers must contain at least two DCs.")

# Normalize shared pool per DC
shared = raw["shared_pool"]
for dc in dc_list:
    if dc not in shared:
        raise SystemExit(f"Shared pool missing DC: {dc}")

# Normalize private pools per customer per DC
private = raw["private_pools"]
for customer, pools in private.items():
    for dc in dc_list:
        if dc not in pools:
            raise SystemExit(f"Private pool for {customer} missing DC: {dc}")

# Normalize domain minimums
domains = raw["domains"]
for domain, cfg in domains.items():
    for field in ["min_cpu", "min_mem", "min_storage"]:
        if field not in cfg:
            raise SystemExit(f"Domain {domain} missing field: {field}")

# Normalize POD + Pair-POD mapping
pods = raw["pods"]
for pod_name, pod_cfg in pods.items():
    if "dc" not in pod_cfg:
        raise SystemExit(f"POD {pod_name} missing dc field.")
    if pod_cfg["dc"] not in dc_list:
        raise SystemExit(f"POD {pod_name} references unknown DC.")

    # Pair-POD DC must be opposite
    if "pair_dc" not in pod_cfg:
        raise SystemExit(f"POD {pod_name} missing pair_dc field.")
    if pod_cfg["pair_dc"] not in dc_list:
        raise SystemExit(f"POD {pod_name} pair_dc references unknown DC.")

output = {
    "data_centers": dc_list,
    "shared_pool": shared,
    "private_pools": private,
    "domains": domains,
    "pods": pods
}

print(json.dumps(output, indent=2))
