#!/usr/bin/env python3
"""
Capability: Generate a resource usage report for all Kubernetes pods.
Collects:
- Pod name
- Namespace
- Container resource requests/limits
- Live CPU/memory usage (kubectl top)
"""

import os
import json
import subprocess

KUBECONFIG = os.environ.get("KUBECONFIG")
if not KUBECONFIG:
    raise SystemExit("KUBECONFIG is required.")

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True)

# Get pod specs
pods_raw = run("kubectl get pods --all-namespaces -o json")
pods = json.loads(pods_raw)

# Get live metrics
try:
    metrics_raw = run("kubectl top pods --all-namespaces --no-headers")
    metrics = {}
    for line in metrics_raw.splitlines():
        ns, pod, cpu, mem = line.split()[:4]
        metrics[(ns, pod)] = {"cpu": cpu, "memory": mem}
except Exception:
    metrics = {}

output = []

for item in pods.get("items", []):
    metadata = item.get("metadata", {})
    spec = item.get("spec", {})

    ns = metadata.get("namespace")
    pod = metadata.get("name")

    entry = {
        "name": pod,
        "namespace": ns,
        "live_usage": metrics.get((ns, pod), {}),
        "containers": []
    }

    for c in spec.get("containers", []):
        resources = c.get("resources", {})
        entry["containers"].append({
            "name": c.get("name"),
            "requests": resources.get("requests", {}),
            "limits": resources.get("limits", {})
        })

    output.append(entry)

print(json.dumps(output, indent=2))
