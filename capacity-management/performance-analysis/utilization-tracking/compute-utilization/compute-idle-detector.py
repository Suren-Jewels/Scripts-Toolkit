#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Capability: Cross‑Cloud Compute Idle Resource Detector
# Purpose   : Identify idle or underutilized compute instances across GCP, Azure,
#             and AWS using utilization thresholds and multi‑metric scoring.
# Output    : JSON (idle candidates + scoring details)
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

# ----------------------------- CONFIG -----------------------------------------

CPU_THRESHOLD = 0.05        # 5% CPU
RAM_THRESHOLD = 0.10        # 10% RAM
NET_THRESHOLD = 1024 * 1024 # 1 MB/hour
DISK_THRESHOLD = 1024 * 1024 # 1 MB/hour

# ----------------------------- FUNCTIONS --------------------------------------

def load_reports():
    reports = []
    for fname in os.listdir(ROLLUP_DIR):
        if fname.endswith(".json"):
            with open(os.path.join(ROLLUP_DIR, fname), "r") as f:
                try:
                    data = json.load(f)
                    reports.append(data)
                except Exception:
                    continue
    return reports


def is_idle(instance):
    cpu = instance.get("cpu_avg", 0)
    ram = instance.get("ram_avg", 0)
    net_rx = instance.get("net_rx_avg", 0)
    net_tx = instance.get("net_tx_avg", 0)
    disk_read = instance.get("disk_read_avg", 0)
    disk_write = instance.get("disk_write_avg", 0)

    return (
        cpu <= CPU_THRESHOLD and
        ram <= RAM_THRESHOLD and
        (net_rx + net_tx) <= NET_THRESHOLD and
        (disk_read + disk_write) <= DISK_THRESHOLD
    )


def extract_instances(report):
    # Normalize across clouds
    if "instance_reports" in report:
        return report["instance_reports"]
    return []


# ----------------------------- MAIN LOGIC -------------------------------------

reports = load_reports()
idle_instances = []

for report in reports:
    instances = extract_instances(report)
    for inst in instances:
        if is_idle(inst):
            idle_instances.append(inst)

output = {
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "idle_instance_count": len(idle_instances),
    "idle_instances": idle_instances
}

print(json.dumps(output, indent=2))
