#!/usr/bin/env python3
# latency-analyzer.py

import json
import sys
import os
from datetime import datetime

# ------------------------------------------------------------
# Inputs:
#   LATENCY_FILES   - comma-separated list of JSON latency files
#   OUTPUT_FILE     - output JSON file (default: latency-analysis.json)
# ------------------------------------------------------------

latency_files = os.environ.get("LATENCY_FILES")
output_file = os.environ.get("OUTPUT_FILE", "latency-analysis.json")

if not latency_files:
    print("ERROR: LATENCY_FILES environment variable is required.", file=sys.stderr)
    sys.exit(1)

files = [f.strip() for f in latency_files.split(",") if f.strip()]

for f in files:
    if not os.path.isfile(f):
        print(f"ERROR: Latency file not found: {f}", file=sys.stderr)
        sys.exit(1)

def load_json(path):
    with open(path, "r") as f:
        return json.load(f)

records = []
for f in files:
    data = load_json(f)
    endpoints = data.get("endpoints", [])
    for ep in endpoints:
        records.append(ep)

def percentile(values, p):
    if not values:
        return None
    values = sorted(values)
    k = (len(values) - 1) * (p / 100)
    f = int(k)
    c = min(f + 1, len(values) - 1)
    if f == c:
        return values[f]
    return values[f] + (values[c] - values[f]) * (k - f)

latencies = [r["latency_ms"] for r in records if isinstance(r.get("latency_ms"), int)]
success_count = sum(1 for r in records if r.get("success") is True)
total_count = len(records)

analysis = {
    "meta": {
        "collector": "latency-analyzer.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "input_files": files
    },
    "summary": {
        "total_endpoints": total_count,
        "successful_requests": success_count,
        "success_rate": (success_count / total_count) if total_count else 0,
        "p50_latency_ms": percentile(latencies, 50),
        "p95_latency_ms": percentile(latencies, 95),
        "p99_latency_ms": percentile(latencies, 99)
    },
    "endpoints": records
}

with open(output_file, "w") as f:
    json.dump(analysis, f, indent=2)
