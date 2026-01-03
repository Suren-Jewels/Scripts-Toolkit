#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Cross‑Cloud Load Balancer Utilization Summary
# Purpose   : Aggregate utilization metrics for GCP, Azure, and AWS load
#             balancers — including request volume, backend saturation,
#             throughput, latency, and error rates.
# Output    : JSON (per‑LB + cloud rollup)
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


def extract_lb_entries(report):
    # Normalize across clouds
    if "lb_reports" in report:
        return report["lb_reports"]
    if "loadbalancer_reports" in report:
        return report["loadbalancer_reports"]
    return []


def summarize(lb):
    return {
        "cloud": lb.get("cloud"),
        "name": lb.get("name"),
        "region": lb.get("region"),
        "requests_per_sec": lb.get("requests_per_sec", 0),
        "throughput_bps": lb.get("throughput_bps", 0),
        "latency_ms": lb.get("latency_ms", 0),
        "error_rate": lb.get("error_rate", 0),
        "backend_saturation": lb.get("backend_saturation", 0)
    }

# ----------------------------- MAIN LOGIC -------------------------------------

reports = load_reports()
lb_entries = []

for report in reports:
    lb_entries.extend(extract_lb_entries(report))

summaries = [summarize(lb) for lb in lb_entries]

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "lb_count": len(summaries),
    "lb_utilization": summaries
}

print(json.dumps(output, indent=2))
