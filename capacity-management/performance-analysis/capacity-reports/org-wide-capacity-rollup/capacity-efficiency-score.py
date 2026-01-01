#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Cross‑Cloud Capacity Efficiency Scoring
# Purpose   : Compute an efficiency score for compute, storage, and network
#             capacity across GCP, Azure, and AWS using weighted capacity
#             consumption ratios.
# Output    : JSON (efficiency scores + contributing factors)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

import json
import os
import sys
from datetime import datetime

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


def extract_compute(report):
    return report.get("compute_capacity", {})


def extract_storage(report):
    return report.get("storage_capacity", {})


def extract_network(report):
    return report.get("network_capacity", {})


def ratio(used, total):
    if total in (0, None):
        return 0
    return used / total


def score_compute(c):
    used = c.get("used_cores", 0)
    total = c.get("total_cores", 0)
    return ratio(used, total)


def score_storage(s):
    used = s.get("used_gb", 0)
    total = s.get("total_gb", 0)
    return ratio(used, total)


def score_network(n):
    used = n.get("used_bandwidth_gbps", 0)
    total = n.get("total_bandwidth_gbps", 0)
    return ratio(used, total)


# ----------------------------- MAIN LOGIC -------------------------------------

reports = load_reports()

compute_scores = []
storage_scores = []
network_scores = []

for report in reports:
    compute_scores.append(score_compute(extract_compute(report)))
    storage_scores.append(score_storage(extract_storage(report)))
    network_scores.append(score_network(extract_network(report)))

compute_score = sum(compute_scores) / len(compute_scores) if compute_scores else 0
storage_score = sum(storage_scores) / len(storage_scores) if storage_scores else 0
network_score = sum(network_scores) / len(network_scores) if network_scores else 0

# Weighted capacity efficiency score
efficiency_score = (
    (compute_score * 0.5) +
    (storage_score * 0.3) +
    (network_score * 0.2)
)

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "compute_capacity_score": compute_score,
    "storage_capacity_score": storage_score,
    "network_capacity_score": network_score,
    "capacity_efficiency_score": efficiency_score
}

print(json.dumps(output, indent=2))
