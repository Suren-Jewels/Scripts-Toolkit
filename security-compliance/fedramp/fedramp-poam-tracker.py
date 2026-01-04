#!/usr/bin/env python3
"""
FedRAMP POA&M Tracker
Tracks open, in-progress, and closed POA&M items.
"""

import json
import argparse
from pathlib import Path

def load_poam(path: Path):
    with open(path, "r") as f:
        return json.load(f)

def summarize(poam_items):
    summary = {"Open": 0, "In Progress": 0, "Closed": 0}
    for item in poam_items:
        status = item.get("status", "Open")
        if status not in summary:
            summary[status] = 0
        summary[status] += 1
    return summary

def main():
    parser = argparse.ArgumentParser(description="Track POA&M items.")
    parser.add_argument("--poam", required=True, help="POA&M JSON file")
    args = parser.parse_args()

    poam = load_poam(Path(args.poam))
    summary = summarize(poam.get("items", []))

    print("[RESULT] POA&M Summary:")
    for status, count in summary.items():
        print(f" - {status}: {count}")

if __name__ == "__main__":
    main()
