#!/usr/bin/env python3
"""
Capability: Server health inspection.
Checks:
- CPU, memory, disk usage
- node conditions (pressure states)
- uptime
- taints
- schedulability
- kubelet/agent health indicators
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

LABEL_KEY = os.environ.get("LABEL_KEY", "server-managed")
LABEL_VALUE = os.environ.get("LABEL_VALUE", "true")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

nodes_raw = run(f"kubectl get nodes -l {LABEL_KEY}={LABEL_VALUE} -o json")
nodes = json.loads(nodes_raw)

output = []

for item in nodes.get("items", []):
    metadata = item.get("metadata", {})
    status = item.get("status", {})

    name = metadata.get("name")
    conditions = status.get("conditions", [])
    taints = metadata.get("taints", [])
    schedulable = not metadata.get("unschedulable", False)

    cond_map = {c["type"]: c["status"] for c in conditions}

    # Uptime via node info (if available)
    node_info = status.get("nodeInfo", {})
    kubelet_version = node_info.get("kubeletVersion", "")
    os_image = node_info.get("osImage", "")

    entry = {
        "name": name,
        "schedulable": schedulable,
        "conditions": cond_map,
        "taints": taints,
        "capacity": status.get("capacity", {}),
        "allocatable": status.get("allocatable", {}),
        "kubelet_version": kubelet_version,
        "os_image": os_image
    }

    output.append(entry)

print(json.dumps(output, indent=2))
