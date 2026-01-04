#!/usr/bin/env python3
"""
FedRAMP SSP Generator
Creates SSP section templates based on system metadata and control mappings.
"""

import json
import argparse
from pathlib import Path

SSP_TEMPLATE = """
System Security Plan (SSP)
==========================

System Name: {system_name}
System Owner: {system_owner}
Authorization Boundary: {boundary}

Implemented Controls Summary:
{controls}
"""

def load_json(path: Path):
    with open(path, "r") as f:
        return json.load(f)

def format_controls(controls):
    return "\n".join([f" - {c}: {details}" for c, details in controls.items()])

def main():
    parser = argparse.ArgumentParser(description="Generate SSP section templates.")
    parser.add_argument("--metadata", required=True, help="System metadata JSON")
    parser.add_argument("--controls", required=True, help="Control mapping JSON")
    parser.add_argument("--output", required=True, help="Output SSP file")
    args = parser.parse_args()

    metadata = load_json(Path(args.metadata))
    control_map = load_json(Path(args.controls))

    ssp_content = SSP_TEMPLATE.format(
        system_name=metadata.get("system_name", "UNKNOWN"),
        system_owner=metadata.get("system_owner", "UNKNOWN"),
        boundary=metadata.get("authorization_boundary", "UNDEFINED"),
        controls=format_controls(control_map)
    )

    with open(args.output, "w") as f:
        f.write(ssp_content)

    print(f"[RESULT] SSP section generated → {args.output}")

if __name__ == "__main__":
    main()
