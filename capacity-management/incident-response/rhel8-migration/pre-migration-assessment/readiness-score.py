pre-migration-assessment/
    -> readiness-score.py
    ->
#!/usr/bin/env python3
"""
Capability: Generates a readiness score for RHEL7 → RHEL8 migration.

Inputs:
    - compatibility.json (output from compatibility-scanner.py)
Scoring Model:
    100 = Fully ready
    70  = Minor issues
    40  = Major blockers
    0   = Migration not allowed

Score deductions:
    - Removed packages:        -30
    - Deprecated modules:      -40
    - Unsupported services:    -30
"""

import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: readiness-score.py <compatibility.json>")

compat_file = sys.argv[1]

with open(compat_file) as f:
    issues = json.load(f)

score = 100

if issues.get("removed_packages"):
    score -= 30

if issues.get("deprecated_modules"):
    score -= 40

if issues.get("unsupported_services"):
    score -= 30

if score < 0:
    score = 0

print(json.dumps({"readiness_score": score}, indent=2))
