#!/usr/bin/env python3
"""
Capability: Detailed Kubernetes pod walk.
Collects:
- Metadata (name, namespace, uid)
- Labels and annotations
- Container statuses
- Resource requests/limits
- Node placement
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
    spec = item.get("spec", {})
    status = item.get("status", {})

    entry = {
        "name": metadata.get("name"),
        "namespace": metadata.get("namespace"),
        "uid": metadata.get("uid"),
        "labels": metadata.get("labels", {}),
        "annotations": metadata.get("annotations", {}),
        "node": spec.get("nodeName"),
        "containers": [],
    }

    for c in spec.get("containers", []):
        cname = c.get("name")
        resources = c.get("resources", {})
        entry["containers"].append({
            "name": cname,
            "requests": resources.get("requests", {}),
            "limits": resources.get("limits", {})
        })

    output.append(entry)

print(json.dumps(output, indent=2))
