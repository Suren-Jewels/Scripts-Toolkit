#!/usr/bin/env python3
"""
FedRAMP Authorization Boundary Validator
Ensures system components are correctly included/excluded from the FedRAMP boundary.
"""

import json
import argparse
from pathlib import Path

def load_json(path: Path):
    with open(path, "r") as f:
        return json.load(f)

def validate_boundary(boundary, inventory):
    missing = []
    extraneous = []

    boundary_items = set(boundary.get("components", []))
    inventory_items = set(inventory.get("assets", []))

    for item in boundary_items:
        if item not in inventory_items:
            missing.append(item)

    for item in inventory_items:
        if item not in boundary_items:
            extraneous.append(item)

    return missing, extraneous

def main():
    parser = argparse.ArgumentParser(description="Validate FedRAMP authorization boundary.")
    parser.add_argument("--boundary", required=True, help="Boundary JSON file")
    parser.add_argument("--inventory", required=True, help="Asset inventory JSON file")
    args = parser.parse_args()

    boundary = load_json(Path(args.boundary))
    inventory = load_json(Path(args.inventory))

    missing, extraneous = validate_boundary(boundary, inventory)

    print("[RESULT] Boundary Validation:")
    if missing:
        print(" - Missing from inventory:")
        for m in missing:
            print(f"    * {m}")
    if extraneous:
        print(" - Not declared in boundary:")
        for e in extraneous:
            print(f"    * {e}")

    if not missing and not extraneous:
        print(" - Boundary is fully aligned.")

if __name__ == "__main__":
    main()
