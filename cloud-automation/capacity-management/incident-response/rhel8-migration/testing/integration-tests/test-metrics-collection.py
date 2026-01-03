#!/usr/bin/env python3
# Capability: Ensure metrics collection accuracy.

import os
import json
import sys

metrics_dir = "metrics"

if not os.path.isdir(metrics_dir):
    print("[FAIL] Metrics directory missing")
    raise SystemExit(1)

required = [
    "dashboard-export.json",
    "weekly-report.json"
]

missing = [f for f in required if not os.path.isfile(os.path.join(metrics_dir, f))]

if missing:
    print(json.dumps({"missing_metrics": missing}, indent=2))
    raise SystemExit(1)

print(json.dumps({"metrics_status": "OK"}, indent=2))
