#!/usr/bin/env python3
"""
Capability: Generate a restart report for all Kubernetes pods.
Collects:
- Pod name
- Namespace
- Total restart count
- Per-container restart counts
- Last restart reason (if available)
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

pods_raw = run("kubectl get pods --all-namespaces -o json")
pods = json.loads(pods_raw)

output = []

for item in pods.get("items", []):
    metadata = item.get("metadata", {})
    status = item.get("status", {})

    containers = status.get("containerStatuses", [])
    total_restarts = sum(c.get("restartCount", 0) for c in containers)

    entry = {
        "name": metadata.get("name"),
        "namespace": metadata.get("namespace"),
        "total_restarts": total_restarts,
        "containers": []
    }

    for c in containers:
        entry["containers"].append({
            "name": c.get("name"),
            "restart_count": c.get("restartCount", 0),
            "last_state": c.get("lastState", {}),
            "state": c.get("state", {})
        })

    output.append(entry)

print(json.dumps(output, indent=2))
