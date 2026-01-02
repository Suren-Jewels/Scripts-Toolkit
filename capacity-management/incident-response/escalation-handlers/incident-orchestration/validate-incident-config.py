incident-orchestration/
    -> validate-incident-config.py
    ->
#!/usr/bin/env python3
"""
Capability: Validate escalation-policy.json and escalation-matrix.yaml.
Checks:
    - Required keys exist
    - Teams referenced in policy exist in matrix
"""

import json
import yaml
import sys
import os

POLICY = "escalation-handlers/incident-orchestration/escalation-policy.json"
MATRIX = "escalation-handlers/incident-orchestration/escalation-matrix.yaml"

if not os.path.isfile(POLICY):
    raise SystemExit("Missing escalation-policy.json")

if not os.path.isfile(MATRIX):
    raise SystemExit("Missing escalation-matrix.yaml")

with open(POLICY) as f:
    policy = json.load(f)

with open(MATRIX) as f:
    matrix = yaml.safe_load(f)

teams = matrix.get("teams", {})

errors = []

for sev, cfg in policy.items():
    team = cfg.get("oncall")
    if team not in teams and team != "none":
        errors.append(f"Team '{team}' referenced in severity '{sev}' does not exist in matrix.")

if errors:
    print("Validation errors:")
    for e in errors:
        print("-", e)
    sys.exit(1)

print("Incident configuration validated successfully.")
