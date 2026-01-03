#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Cross‑Cloud Storage Growth Analyzer
# Purpose   : Analyze historical storage usage across GCP, Azure, and AWS to
#             detect growth trends, anomalies, and forecast future consumption.
# Output    : JSON (growth trends + anomaly flags + forecast)
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

# ----------------------------- FUNCTIONS --------------------------------------

def load_reports():
    reports = []
    for fname in os.listdir(ROLLUP_DIR):
        if fname.endswith(".json"):
            try:
                with open(os.path.join(ROLLUP_DIR, fname), "r") as f:
                    reports.append(json.load(f))
            except Exception:
                continue
    return reports


def extract_storage_points(report):
    # Normalize across clouds
    if "filestore_reports" in report:
        return report["filestore_reports"]
    if "storage_reports" in report:
        return report["storage_reports"]
    return []


def compute_growth(values):
    if len(values) < 2:
        return 0, 0

    deltas = [values[i] - values[i - 1] for i in range(1, len(values))]
    avg_growth = mean(deltas)
    anomaly = any(abs(d) > (avg_growth * 3) for d in deltas if avg_growth != 0)

    return avg_growth, anomaly


# ----------------------------- MAIN LOGIC -------------------------------------

reports = load_reports()
storage_points = []

for report in reports:
    storage_points.extend(extract_storage_points(report))

# Extract capacity or usage values
usage_values = [
    sp.get("capacity_gb") or
    sp.get("used_bytes") or
    sp.get("size_gb") or
    0
    for sp in storage_points
]

avg_growth, anomaly_flag = compute_growth(usage_values)

forecast_next = usage_values[-1] + avg_growth if usage_values else 0

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "sample_count": len(usage_values),
    "average_growth_per_interval": avg_growth,
    "anomaly_detected": anomaly_flag,
    "forecast_next_interval": forecast_next
}

print(json.dumps(output, indent=2))
