#!/usr/bin/env python3
# uptime-rollup.py

import json
import sys
import os
from datetime import datetime

UPTIME_FILES = os.environ.get("UPTIME_FILES")
OUTPUT_FILE = os.environ.get("OUTPUT_FILE", "uptime-analysis.json")

if not UPTIME_FILES:
    print("ERROR: UPTIME_FILES environment variable is required.", file=sys.stderr)
    sys.exit(1)

files = [f.strip() for f in UPTIME_FILES.split(",") if f.strip()]

for f in files:
    if not os.path.isfile(f):
        print(f"ERROR: Uptime file not found: {f}", file=sys.stderr)
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

total = len(records)
successes = sum(1 for r in records if r.get("success") is True)
success_rate = (successes / total) if total else 0

analysis = {
    "meta": {
        "collector": "uptime-rollup.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "input_files": files
    },
    "summary": {
        "total_endpoints": total,
        "success_count": successes,
        "success_rate": success_rate
    },
    "endpoints": records
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(analysis, f, indent=2)
