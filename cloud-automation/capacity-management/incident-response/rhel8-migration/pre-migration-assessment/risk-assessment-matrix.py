pre-migration-assessment/
    -> risk-assessment-matrix.py
    ->
#!/usr/bin/env python3
"""
Capability: Categorize hosts by migration risk (LOW / MEDIUM / HIGH).
Inputs:
    - readiness score
    - number of blockers
"""

import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: risk-assessment-matrix.py <readiness.json>")

readiness_file = sys.argv[1]

with open(readiness_file) as f:
    data = json.load(f)

score = data.get("readiness_score", 0)

if score >= 80:
    risk = "LOW"
elif score >= 50:
    risk = "MEDIUM"
else:
    risk = "HIGH"

print(json.dumps({"risk_level": risk}, indent=2))
