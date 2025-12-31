#!/usr/bin/env python3
"""
Capability: Compute reserve pool capacity.
Aggregates:
- total CPU/memory capacity
- total allocatable CPU/memory
- per-node breakdown
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

LABEL_KEY = os.environ.get("LABEL_KEY", "reserve-pool")
LABEL_VALUE = os.environ.get("LABEL_VALUE", "true")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

nodes_raw = run(f"kubectl get nodes -l {LABEL_KEY}={LABEL_VALUE} -o json")
nodes = json.loads(nodes_raw)

output = {
    "total_capacity": {"cpu": 0, "memory": 0},
    "total_allocatable": {"cpu": 0, "memory": 0},
    "nodes": []
}

def parse_cpu(cpu_str):
    if cpu_str.endswith("m"):
        return int(cpu_str[:-1]) / 1000
    return int(cpu_str)

def parse_mem(mem_str):
    if mem_str.endswith("Ki"):
        return int(mem_str[:-2]) / 1024 / 1024
    if mem_str.endswith("Mi"):
        return int(mem_str[:-2]) / 1024
    if mem_str.endswith("Gi"):
        return int(mem_str[:-2])
    return int(mem_str)

for item in nodes.get("items", []):
    name = item["metadata"]["name"]
    cap = item["status"]["capacity"]
    alloc = item["status"]["allocatable"]

    cpu_cap = parse_cpu(cap["cpu"])
    mem_cap = parse_mem(cap["memory"])

    cpu_alloc = parse_cpu(alloc["cpu"])
    mem_alloc = parse_mem(alloc["memory"])

    output["total_capacity"]["cpu"] += cpu_cap
    output["total_capacity"]["memory"] += mem_cap

    output["total_allocatable"]["cpu"] += cpu_alloc
    output["total_allocatable"]["memory"] += mem_alloc

    output["nodes"].append({
        "name": name,
        "capacity": {"cpu": cpu_cap, "memory": mem_cap},
        "allocatable": {"cpu": cpu_alloc, "memory": mem_alloc}
    })

print(json.dumps(output, indent=2))
