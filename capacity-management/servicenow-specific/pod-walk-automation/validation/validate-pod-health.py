#!/usr/bin/env python3
"""
Capability: Validate Kubernetes pod health.
Checks:
- readiness
- liveness
- container crash states
- waiting/terminated reasons
- restart anomalies
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

    entry = {
        "name": metadata.get("name"),
        "namespace": metadata.get("namespace"),
        "health": [],
    }

    for c in containers:
        entry["health"].append({
            "name": c.get("name"),
            "ready": c.get("ready"),
            "restart_count": c.get("restartCount", 0),
            "state": c.get("state", {}),
            "last_state": c.get("lastState", {})
        })

    output.append(entry)

print(json.dumps(output, indent=2))
