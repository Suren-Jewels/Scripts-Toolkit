#!/usr/bin/env python3
"""
IL Posture Validator
Validates device posture against IL4/IL5 requirements.
"""

import argparse
import json
from pathlib import Path

REQUIRED_FLAGS = [
    "disk_encrypted",
    "host_firewall_enabled",
    "av_installed",
    "av_realtime_enabled",
    "os_supported",
    "mfa_required"
]

def load_json(path: Path):
    if not path.exists():
        print(f"[ERROR] JSON file not found: {path}")
        raise SystemExit(1)
    with open(path, "r") as f:
        return json.load(f)

def validate_posture(device: dict) -> dict:
    failures = []
    for flag in REQUIRED_FLAGS:
        if not device.get(flag, False):
            failures.append(flag)
    return {
        "device_id": device.get("device_id", "UNKNOWN"),
        "compliant": len(failures) == 0,
        "failed_checks": failures
    }

def main():
    parser = argparse.ArgumentParser(description="Validate IL4/IL5 device posture.")
    parser.add_argument("--posture", required=True, help="Device posture JSON file")
    args = parser.parse_args()

    posture_data = load_json(Path(args.posture))
    devices = posture_data.get("devices", [])

    print("[RESULT] IL Posture Validation")
    non_compliant = 0

    for device in devices:
        result = validate_posture(device)
        line = f" - {result['device_id']}: {'COMPLIANT' if result['compliant'] else 'NON-COMPLIANT'}"
        print(line)
        if not result["compliant"]:
            non_compliant += 1
            for fc in result["failed_checks"]:
                print(f"    * Failed: {fc}")

    if non_compliant == 0:
        print("All devices meet IL posture requirements.")
        raise SystemExit(0)
    else:
        print(f"{non_compliant} device(s) failed IL posture requirements.")
        raise SystemExit(2)

if __name__ == "__main__":
    main()
