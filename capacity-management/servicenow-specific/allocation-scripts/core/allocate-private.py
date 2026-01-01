#!/usr/bin/env python3
"""
Capability: Allocate private customer pool capacity across all domains.
Implements:
- per-customer isolation
- multi-DC private pool allocation
- POD and Pair-POD balancing per customer
- domain minimum guarantees
"""

import os
import json
import sys

INPUT_FILE = os.environ.get("DISCOVERED_CAPACITY")
if not INPUT_FILE:
    raise SystemExit("DISCOVERED_CAPACITY is required.")

with open(INPUT_FILE) as f:
    data = json.load(f)

dcs = data["data_centers"]
private = data["private_pools"]
domains = data["domains"]
pods = data["pods"]

# Output structure
alloc = {
    "private_allocations": {}
}

def init_remaining(pools):
    return {
        dc: {
            "cpu": pools[dc]["cpu"],
            "mem": pools[dc]["mem"],
            "storage": pools[dc]["storage"]
        }
        for dc in dcs
    }

def consume(remaining, dc, cpu, mem, storage):
    if remaining[dc]["cpu"] < cpu:
        raise SystemExit(f"Insufficient CPU in {dc}")
    if remaining[dc]["mem"] < mem:
        raise SystemExit(f"Insufficient memory in {dc}")
    if remaining[dc]["storage"] < storage:
        raise SystemExit(f"Insufficient storage in {dc}")

    remaining[dc]["cpu"] -= cpu
    remaining[dc]["mem"] -= mem
    remaining[dc]["storage"] -= storage

def record(store, dc, name, cpu, mem, storage):
    store.setdefault(dc, {})
    store[dc][name] = {
        "cpu": cpu,
        "mem": mem,
        "storage": storage
    }

# Process each customer independently
for customer, pools in private.items():
    alloc["private_allocations"][customer] = {}
    store = alloc["private_allocations"][customer]

    # Initialize remaining capacity for this customer
    remaining = init_remaining(pools)

    # Allocate domain minimums (DB, SCV, APP)
    for domain, cfg in domains.items():
        if domain in ["pod", "pairpod"]:
            continue  # handled separately

        min_cpu = cfg["min_cpu"]
        min_mem = cfg["min_mem"]
        min_storage = cfg["min_storage"]

        # Even distribution across DCs
        per_dc_cpu = min_cpu // len(dcs)
        per_dc_mem = min_mem // len(dcs)
        per_dc_storage = min_storage // len(dcs)

        for dc in dcs:
            consume(remaining, dc, per_dc_cpu, per_dc_mem, per_dc_storage)
            record(store, dc, domain, per_dc_cpu, per_dc_mem, per_dc_storage)

    # Allocate POD + Pair-POD with balancing
    for pod_name, cfg in pods.items():
        dc_pod = cfg["dc"]
        dc_pair = cfg["pair_dc"]

        pod_min = domains["pod"]
        pair_min = domains["pairpod"]

        # Step 1: allocate minimums
        consume(remaining, dc_pod, pod_min["min_cpu"], pod_min["min_mem"], pod_min["min_storage"])
        consume(remaining, dc_pair, pair_min["min_cpu"], pair_min["min_mem"], pair_min["min_storage"])

        record(store, dc_pod, pod_name, pod_min["min_cpu"], pod_min["min_mem"], pod_min["min_storage"])
        record(store, dc_pair, f"{pod_name}-pair", pair_min["min_cpu"], pair_min["min_mem"], pair_min["min_storage"])

        # Step 2: best-effort balancing
        extra_cpu = min(remaining[dc_pod]["cpu"], remaining[dc_pair]["cpu"])
        extra_mem = min(remaining[dc_pod]["mem"], remaining[dc_pair]["mem"])
        extra_storage = min(remaining[dc_pod]["storage"], remaining[dc_pair]["storage"])

        half_cpu = extra_cpu // 2
        half_mem = extra_mem // 2
        half_storage = extra_storage // 2

        consume(remaining, dc_pod, half_cpu, half_mem, half_storage)
        consume(remaining, dc_pair, half_cpu, half_mem, half_storage)

        store[dc_pod][pod_name]["cpu"] += half_cpu
        store[dc_pod][pod_name]["mem"] += half_mem
        store[dc_pod][pod_name]["storage"] += half_storage

        store[dc_pair][f"{pod_name}-pair"]["cpu"] += half_cpu
        store[dc_pair][f"{pod_name}-pair"]["mem"] += half_mem
        store[dc_pair][f"{pod_name}-pair"]["storage"] += half_storage

print(json.dumps(alloc, indent=2))
