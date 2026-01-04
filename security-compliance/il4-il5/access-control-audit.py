#!/usr/bin/env python3
"""
Access Control Audit
Audits RBAC assignments for excessive privilege against IL4/IL5 role policies.
"""

import argparse
import json
from pathlib import Path

# Example of "high risk" roles for illustration
HIGH_RISK_ROLES = [
    "GlobalAdmin",
    "Owner",
    "SecurityAdmin"
]

def load_json(path: Path):
    if not path.exists():
        print(f"[ERROR] JSON file not found: {path}")
        raise SystemExit(1)
    with open(path, "r") as f:
        return json.load(f)

def main():
    parser = argparse.ArgumentParser(description="Audit RBAC and access control assignments.")
    parser.add_argument("--assignments", required=True, help="RBAC assignments JSON")
    args = parser.parse_args()

    data = load_json(Path(args.assignments))
    assignments = data.get("assignments", [])

    print("[RESULT] Access Control Audit")
    high_risk_findings = 0

    for entry in assignments:
        user = entry.get("principal", "UNKNOWN")
        role = entry.get("role", "UNKNOWN")
        scope = entry.get("scope", "/")

        flag = "OK"
        if role in HIGH_RISK_ROLES and scope == "/":
            flag = "HIGH-RISK"
            high_risk_findings += 1

        print(f" - {user} → {role} @ {scope} [{flag}]")

    if high_risk_findings == 0:
        print("No high‑risk RBAC findings detected.")
        raise SystemExit(0)
    else:
        print(f"{high_risk_findings} high‑risk RBAC finding(s) detected.")
        raise SystemExit(2)

if __name__ == "__main__":
    main()
