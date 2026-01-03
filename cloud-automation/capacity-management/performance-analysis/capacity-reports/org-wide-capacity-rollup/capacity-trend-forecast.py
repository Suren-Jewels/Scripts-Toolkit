#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Capacity Forecasting Engine
# Purpose   : Forecast future compute, storage, and network capacity usage based
#             on historical rollup data and linear growth modeling.
# Output    : JSON (forecasted values + confidence indicators)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

import json
import os
import sys
from datetime import datetime
from statistics import mean

# ----------------------------- VALIDATION -------------------------------------

REQUIRED_ENV = ["ROLLUP_INPUT_DIR", "FORECAST_INTERVALS"]

for var in REQUIRED_ENV:
    if var not in os.environ:
        print(f"ERROR: Missing required environment variable: {var}", file=sys.stderr)
        sys.exit(1)

ROLLUP_DIR = os.environ["ROLLUP_INPUT_DIR"]
INTERVALS = int(os.environ["FORECAST_INTERVALS"])

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


def extract_series(rollups, key):
    series = []
    for r in rollups:
        section = r.get(key, {})
        if key == "compute_capacity":
            series.append(section.get("used_cores", 0))
        elif key == "storage_capacity":
            series.append(section.get("used_gb", 0))
        elif key == "network_capacity":
            series.append(section.get("used_bandwidth_gbps", 0))
    return series


def forecast(values, intervals):
    if len(values) < 2:
        return [values[-1] if values else 0] * intervals

    deltas = [values[i] - values[i - 1] for i in range(1, len(values))]
    slope = mean(deltas)

    return [values[-1] + slope * (i + 1) for i in range(intervals)]

# ----------------------------- MAIN LOGIC -------------------------------------

rollups = load_rollups()

compute_series = extract_series(rollups, "compute_capacity")
storage_series = extract_series(rollups, "storage_capacity")
network_series = extract_series(rollups, "network_capacity")

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "forecast_intervals": INTERVALS,
    "compute_forecast": forecast(compute_series, INTERVALS),
    "storage_forecast": forecast(storage_series, INTERVALS),
    "network_forecast": forecast(network_series, INTERVALS),
    "sample_count": len(rollups)
}

print(json.dumps(output, indent=2))
