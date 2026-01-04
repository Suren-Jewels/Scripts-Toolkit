#!/usr/bin/env python3
"""
FedRAMP Controls Validator
Validates implemented controls against FedRAMP Moderate/High baselines.
"""

import json
import argparse
import sys
from pathlib import Path

def load_json(path: Path):
    if not path.exists():
        print(f"[ERROR] Baseline file not found: {path}")
        sys.exit(1)
    with open(path, "r") as f:
        return json.load(f)

def validate_controls(implemented_controls, baseline_controls):
    missing = []
    for control in baseline_controls:
        if control not in implemented_controls:
            missing.append(control)
    return missing

def main():
    parser = argparse.ArgumentParser(description="Validate FedRAMP control implementation.")
    parser.add_argument("--implemented", required=True, help="Path to implemented-controls.json")
    parser.add_argument("--baseline", required=True, help="Path to FedRAMP baseline JSON")
    args = parser.parse_args()

    implemented = load_json(Path(args.implemented))
    baseline = load_json(Path(args.baseline))

    missing_controls = validate_controls(implemented.get("controls", []), baseline.get("controls", []))

    if missing_controls:
        print("[RESULT] Missing FedRAMP Controls:")
        for c in missing_controls:
            print(f" - {c}")
        sys.exit(2)
    else:
        print("[RESULT] All FedRAMP controls satisfied.")
        sys.exit(0)

if __name__ == "__main__":
    main()
