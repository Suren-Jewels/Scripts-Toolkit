#!/usr/bin/env python3
# threshold-evaluator.py

import json
import sys
import os
from datetime import datetime

THRESHOLDS_FILE = os.environ.get("THRESHOLDS_FILE")
SLA_ROLLUP_FILE = os.environ.get("SLA_ROLLUP_FILE")
OUTPUT_FILE = os.environ.get("OUTPUT_FILE", "threshold-evaluation.json")

if not THRESHOLDS_FILE:
    print("ERROR: THRESHOLDS_FILE is required.", file=sys.stderr)
    sys.exit(1)

if not SLA_ROLLUP_FILE:
    print("ERROR: SLA_ROLLUP_FILE is required.", file=sys.stderr)
    sys.exit(1)

if not os.path.isfile(THRESHOLDS_FILE):
    print(f"ERROR: Thresholds file not found: {THRESHOLDS_FILE}", file=sys.stderr)
    sys.exit(1)

if not os.path.isfile(SLA_ROLLUP_FILE):
    print(f"ERROR: SLA rollup file not found: {SLA_ROLLUP_FILE}", file=sys.stderr)
    sys.exit(1)

def load_json(path):
    with open(path, "r") as f:
        return json.load(f)

thresholds = load_json(THRESHOLDS_FILE)
rollup = load_json(SLA_ROLLUP_FILE)

sla = rollup.get("sla", {})

latency = sla.get("p95_latency_ms")
error_rate = sla.get("error_rate")
uptime = sla.get("uptime_rate")
sla_score = sla.get("sla_score")

latency_ok = latency is not None and latency <= thresholds.get("max_p95_latency_ms", float("inf"))
error_ok = error_rate is not None and error_rate <= thresholds.get("max_error_rate", float("inf"))
uptime_ok = uptime is not None and uptime >= thresholds.get("min_uptime_rate", 0)
score_ok = sla_score is not None and sla_score >= thresholds.get("min_sla_score", 0)

evaluation = {
    "meta": {
        "collector": "threshold-evaluator.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "thresholds_file": THRESHOLDS_FILE,
        "sla_rollup_file": SLA_ROLLUP_FILE
    },
    "results": {
        "latency_within_threshold": latency_ok,
        "error_rate_within_threshold": error_ok,
        "uptime_within_threshold": uptime_ok,
        "sla_score_within_threshold": score_ok
    },
    "values": {
        "latency_p95_ms": latency,
        "error_rate": error_rate,
        "uptime_rate": uptime,
        "sla_score": sla_score
    },
    "thresholds": thresholds
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(evaluation, f, indent=2)
