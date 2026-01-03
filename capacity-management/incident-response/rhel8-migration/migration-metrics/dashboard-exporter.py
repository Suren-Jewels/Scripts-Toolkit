#!/usr/bin/env python3
# Capability: Export metrics to Grafana/DataDog.

import json
import os

metrics_dir = "metrics"

if not os.path.isdir(metrics_dir):
    print("No metrics directory found.")
    raise SystemExit(0)

export = {}

for file in os.listdir(metrics_dir):
    if not file.endswith(".json"):
        continue
    with open(os.path.join(metrics_dir, file)) as f:
        export[file] = json.load(f)

with open("metrics/dashboard-export.json", "w") as f:
    json.dump(export, f, indent=2)

print("Dashboard export generated: metrics/dashboard-export.json")
