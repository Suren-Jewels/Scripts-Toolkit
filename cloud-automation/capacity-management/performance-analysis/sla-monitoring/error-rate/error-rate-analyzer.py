#!/usr/bin/env python3
# error-rate-analyzer.py

import json
import sys
import os
from datetime import datetime

ERROR_FILES = os.environ.get("ERROR_FILES")
OUTPUT_FILE = os.environ.get("OUTPUT_FILE", "error-rate-analysis.json")

if not ERROR_FILES:
    print("ERROR: ERROR_FILES environment variable is required.", file=sys.stderr)
    sys.exit(1)

files = [f.strip() for f in ERROR_FILES.split(",") if f.strip()]

for f in files:
    if not os.path.isfile(f):
        print(f"ERROR: Error-rate file not found: {f}", file=sys.stderr)
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
errors = sum(1 for r in records if r.get("error") is True)
error_rate = (errors / total) if total else 0

analysis = {
    "meta": {
        "collector": "error-rate-analyzer.py",
        "generated_at_utc": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "input_files": files
    },
    "summary": {
        "total_endpoints": total,
        "error_count": errors,
        "error_rate": error_rate
    },
    "endpoints": records
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(analysis, f, indent=2)
