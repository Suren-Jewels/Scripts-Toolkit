#!/usr/bin/env python3
# sla-dashboard-generator.py

import json
import sys
import os
from datetime import datetime

SLA_ROLLUP_FILE = os.environ.get("SLA_ROLLUP_FILE")
THRESHOLD_EVALUATION_FILE = os.environ.get("THRESHOLD_EVALUATION_FILE")
OUTPUT_FILE = os.environ.get("OUTPUT_FILE", "sla-dashboard.json")

if not SLA_ROLLUP_FILE:
    print("ERROR: SLA_ROLLUP_FILE is required.", file=sys.stderr)
    sys.exit(1)

if not THRESHOLD_EVALUATION_FILE:
    print("ERROR: THRESHOLD_EVALUATION_FILE is required.", file=sys.stderr)
    sys.exit(1)

if not os.path.isfile(SLA_ROLLUP_FILE):
    print(f"ERROR: SLA rollup file not found: {SLA_ROLLUP_FILE}", file=sys.stderr)
    sys.exit(1)

if not os.path.isfile(THRESHOLD_EVALUATION_FILE):
    print(f"ERROR: Threshold evaluation file not found: {THRESHOLD_EVALUATION_FILE}", file=sys.stderr)
    sys.exit(1)

def load_json(path):
    with open(path, "r") as f:
        return json.load(f)

rollup = load_json(SLA_ROLLUP_FILE)
thresholds = load_json(THRESHOLD_EVALUATION_FILE)

sla = rollup.get("sla", {})
results = thresholds.get("results", {})
values = thresholds.get("values", {})
threshold_values = thresholds.get("thresholds", {})

dashboard = {
    "meta": {
        "collector": "sla-dashboard-generator.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "inputs": {
            "sla_rollup_file": SLA_ROLLUP_FILE,
            "threshold_evaluation_file": THRESHOLD_EVALUATION_FILE
        }
    },
    "sla_summary": sla,
    "threshold_evaluation": {
        "status": results,
        "values": values,
        "thresholds": threshold_values
    },
    "dashboard": {
        "overall_sla_score": sla.get("sla_score"),
        "meets_all_thresholds": all(results.values()) if results else False
    }
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(dashboard, f, indent=2)
