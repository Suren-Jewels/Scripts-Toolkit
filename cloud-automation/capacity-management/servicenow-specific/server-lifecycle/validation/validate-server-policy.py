#!/usr/bin/env python3
"""
Capability: Validate server policy compliance.
Checks:
- required labels
- required annotations
- required taints
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

LABEL_KEY = os.environ.get("LABEL_KEY", "server-managed")
LABEL_VALUE = os.environ.get("LABEL_VALUE", "true")

REQUIRED_LABELS = os.environ.get("REQUIRED_LABELS", "server-managed,role").split(",")
REQUIRED_ANNOTATIONS = os.environ.get("REQUIRED_ANNOTATIONS", "").split(",")
REQUIRED_TAINTS = os.environ.get("REQUIRED_TAINTS", "").split(",")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

nodes_raw = run(f"kubectl get nodes -l {LABEL_KEY}={LABEL_VALUE} -o json")
nodes = json.loads(nodes_raw)

output = []

for item in nodes.get("items", []):
    metadata = item.get("metadata", {})
    name = metadata.get("name")

    labels = metadata.get("labels", {})
    annotations = metadata.get("annotations", {})
    taints = metadata.get("taints", [])

    missing_labels = [l for l in REQUIRED_LABELS if l and l not in labels]
    missing_annotations = [a for a in REQUIRED_ANNOTATIONS if a and a not in annotations]

    taint_keys = [t.get("key") for t in taints]
    missing_taints = [t for t in REQUIRED_TAINTS if t and t not in taint_keys]

    entry = {
        "name": name,
        "missing_labels": missing_labels,
        "missing_annotations": missing_annotations,
        "missing_taints": missing_taints
    }

    output.append(entry)

print(json.dumps(output, indent=2))
