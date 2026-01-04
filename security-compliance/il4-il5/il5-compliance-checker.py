#!/usr/bin/env python3
"""
IL5 Compliance Checker
Validates implemented controls against IL5 security control matrix.
"""

import argparse
import sys
import yaml
import json
from pathlib import Path

def load_yaml(path: Path):
    if not path.exists():
        print(f"[ERROR] YAML file not found: {path}")
        sys.exit(1)
    with open(path, "r") as f:
        return yaml.safe_load(f)

def load_json(path: Path):
    if not path.exists():
        print(f"[ERROR] JSON file not found: {path}")
        sys.exit(1)
    with open(path, "r") as f:
        return json.load(f)

def validate_controls(matrix, implemented):
    required = set(matrix.get("controls", {}).keys())
    implemented_set = set(implemented.get("controls", []))

    missing = sorted(required - implemented_set)
    extra = sorted(implemented_set - required)

    return missing, extra

def main():
    parser = argparse.ArgumentParser(description="Validate IL5 control implementation.")
    parser.add_argument("--matrix", required=True, help="Path to il5-control-matrix.yaml")
    parser.add_argument("--implemented", required=True, help="Path to implemented-controls.json")
    args = parser.parse_args()

    matrix = load_yaml(Path(args.matrix))
    implemented = load_json(Path(args.implemented))

    missing, extra = validate_controls(matrix, implemented)

    print("[RESULT] IL5 Compliance Check")
    if missing:
        print(" - Missing controls:")
        for c in missing:
            print(f"    * {c}")
    if extra:
        print(" - Implemented but not required (extra):")
        for c in extra:
            print(f"    * {c}")

    if not missing:
        print(" - All required IL5 controls implemented.")
        sys.exit(0)
    else:
        sys.exit(2)

if __name__ == "__main__":
    main()
