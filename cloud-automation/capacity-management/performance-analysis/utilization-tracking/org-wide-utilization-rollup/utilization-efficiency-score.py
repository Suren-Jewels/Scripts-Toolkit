#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Cross‑Cloud Utilization Efficiency Scoring
# Purpose   : Compute an efficiency score for compute, storage, and network
#             utilization across GCP, Azure, and AWS using weighted metrics.
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


def extract_instances(report):
    return report.get("instance_reports", [])


def extract_storage(report):
    return report.get("filestore_reports", []) or report.get("storage_reports", [])


def extract_network(report):
    return report.get("vpc_reports", []) or report.get("network_reports", [])


def score_compute(instances):
    if not instances:
        return 0

    cpu = [i.get("cpu_avg", 0) for i in instances]
    ram = [i.get("ram_avg", 0) for i in instances]

    cpu_score = sum(cpu) / len(cpu)
    ram_score = sum(ram) / len(ram)

    return (cpu_score * 0.6) + (ram_score * 0.4)


def score_storage(storage):
    if not storage:
        return 0

    usage = []
    for s in storage:
        usage.append(
            s.get("capacity_gb") or
            s.get("used_bytes") or
            s.get("size_gb") or
            0
        )

    if not usage:
        return 0

    return sum(usage) / len(usage)


def score_network(network):
    if not network:
        return 0

    throughput = []
    for n in network:
        t = (n.get("throughput_in_sum", 0) + n.get("throughput_out_sum", 0))
        throughput.append(t)

    if not throughput:
        return 0

    return sum(throughput) / len(throughput)


# ----------------------------- MAIN LOGIC -------------------------------------

reports = load_reports()

compute_entries = []
storage_entries = []
network_entries = []

for report in reports:
    compute_entries.extend(extract_instances(report))
    storage_entries.extend(extract_storage(report))
    network_entries.extend(extract_network(report))

compute_score = score_compute(compute_entries)
storage_score = score_storage(storage_entries)
network_score = score_network(network_entries)

# Weighted efficiency score
efficiency_score = (
    (compute_score * 0.5) +
    (storage_score * 0.3) +
    (network_score * 0.2)
)

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "compute_score": compute_score,
    "storage_score": storage_score,
    "network_score": network_score,
    "efficiency_score": efficiency_score
}

print(json.dumps(output, indent=2))
