#!/usr/bin/env python3
"""
Capability: Validate required Kubernetes pod labels.
Checks each pod for required labels and reports:
- missing labels
- present labels
- namespace + pod mapping

Environment:
- REQUIRED_LABELS: comma-separated list (default: app,env,team)
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

required = os.environ.get("REQUIRED_LABELS", "app,env,team").split(",")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

pods_raw = run("kubectl get pods --all-namespaces -o json")
pods = json.loads(pods_raw)

output = []

for item in pods.get("items", []):
    metadata = item.get("metadata", {})
    labels = metadata.get("labels", {})

    missing = [lbl for lbl in required if lbl not in labels]

    entry = {
        "name": metadata.get("name"),
        "namespace": metadata.get("namespace"),
        "labels_present": labels,
        "labels_missing": missing
    }

    output.append(entry)

print(json.dumps(output, indent=2))
