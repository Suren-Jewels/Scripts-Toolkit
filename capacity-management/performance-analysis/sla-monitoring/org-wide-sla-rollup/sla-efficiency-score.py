#!/usr/bin/env python3
# sla-efficiency-score.py

import json
import sys
import os
from datetime import datetime

ROLLUP_FILE = os.environ.get("ROLLUP_FILE")
OUTPUT_FILE = os.environ.get("OUTPUT_FILE", "sla-efficiency-score.json")
HISTORICAL_BASELINE_FILE = os.environ.get("HISTORICAL_BASELINE_FILE", "")

if not ROLLUP_FILE:
    print("ERROR: ROLLUP_FILE is required.", file=sys.stderr)
    sys.exit(1)

if not os.path.isfile(ROLLUP_FILE):
    print(f"ERROR: Rollup file not found: {ROLLUP_FILE}", file=sys.stderr)
    sys.exit(1)

def load_json(path):
    with open(path, "r") as f:
        return json.load(f)

rollup = load_json(ROLLUP_FILE)
sla = rollup.get("sla", {})

latency = sla.get("p95_latency_ms")
error_rate = sla.get("error_rate")
uptime = sla.get("uptime_rate")
sla_score = sla.get("sla_score")

baseline = {
    "baseline_latency_ms": 500,
    "baseline_error_rate": 0.02,
    "baseline_uptime_rate": 0.995,
    "baseline_sla_score": 0.90
}

if HISTORICAL_BASELINE_FILE and os.path.isfile(HISTORICAL_BASELINE_FILE):
    try:
        baseline.update(load_json(HISTORICAL_BASELINE_FILE))
    except Exception:
        pass

latency_eff = baseline["baseline_latency_ms"] / latency if latency else 0
error_eff = (baseline["baseline_error_rate"] / error_rate) if error_rate else 1
uptime_eff = uptime / baseline["baseline_uptime_rate"] if baseline["baseline_uptime_rate"] else 0
score_eff = sla_score / baseline["baseline_sla_score"] if baseline["baseline_sla_score"] else 0

efficiency_score = (
    (latency_eff * 0.25) +
    (error_eff * 0.25) +
    (uptime_eff * 0.25) +
    (score_eff * 0.25)
)

output = {
    "meta": {
        "collector": "sla-efficiency-score.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "rollup_file": ROLLUP_FILE,
        "baseline_file": HISTORICAL_BASELINE_FILE or None
    },
    "efficiency": {
        "latency_efficiency": latency_eff,
        "error_efficiency": error_eff,
        "uptime_efficiency": uptime_eff,
        "sla_score_efficiency": score_eff,
        "overall_efficiency_score": efficiency_score
    },
    "values": {
        "latency_ms": latency,
        "error_rate": error_rate,
        "uptime_rate": uptime,
        "sla_score": sla_score
    },
    "baseline": baseline
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(output, f, indent=2)
