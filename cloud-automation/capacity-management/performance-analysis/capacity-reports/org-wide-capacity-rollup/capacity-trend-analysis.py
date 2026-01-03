#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Capacity Trend Analysis
# Purpose   : Analyze historical capacity rollups to detect growth patterns,
#             saturation trends, and long-term directional changes.
# Output    : JSON (trend slopes + growth indicators + anomaly flags)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

import json
import os
import sys
from datetime import datetime
from statistics import mean

# ----------------------------- VALIDATION -------------------------------------

REQUIRED_ENV = ["ROLLUP_INPUT_DIR"]

for var in REQUIRED_ENV:
    if var not in os.environ:
        print(f"ERROR: Missing required environment variable: {var}", file=sys.stderr)
        sys.exit(1)

ROLLUP_DIR = os.environ["ROLLUP_INPUT_DIR"]

if not os.path.isdir(ROLLUP_DIR):
    print(f"ERROR: ROLLUP_INPUT_DIR does not exist: {ROLLUP_DIR}", file=sys.stderr)
    sys.exit(1)

# ----------------------------- HELPERS ----------------------------------------

def load_rollups():
    rollups = []
    for fname in sorted(os.listdir(ROLLUP_DIR)):
        if fname.endswith(".json"):
            try:
                with open(os.path.join(ROLLUP_DIR, fname), "r") as f:
                    rollups.append(json.load(f))
            except Exception:
                continue
    return rollups


def extract_capacity_points(rollups, key):
    values = []
    for r in rollups:
        section = r.get(key, {})
        if not section:
            continue

        if key == "compute_capacity":
            values.append(section.get("used_cores", 0))
        elif key == "storage_capacity":
            values.append(section.get("used_gb", 0))
        elif key == "network_capacity":
            values.append(section.get("used_bandwidth_gbps", 0))

    return values


def compute_trend(values):
    if len(values) < 2:
        return {"slope": 0, "anomaly": False}

    deltas = [values[i] - values[i - 1] for i in range(1, len(values))]
    slope = mean(deltas)
    anomaly = any(abs(d) > (slope * 3) for d in deltas if slope != 0)

    return {"slope": slope, "anomaly": anomaly}

# ----------------------------- MAIN LOGIC -------------------------------------

rollups = load_rollups()

compute_vals = extract_capacity_points(rollups, "compute_capacity")
storage_vals = extract_capacity_points(rollups, "storage_capacity")
network_vals = extract_capacity_points(rollups, "network_capacity")

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "compute_trend": compute_trend(compute_vals),
    "storage_trend": compute_trend(storage_vals),
    "network_trend": compute_trend(network_vals),
    "sample_count": len(rollups)
}

print(json.dumps(output, indent=2))
