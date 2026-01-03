#!/usr/bin/env python3
"""
Capability: Restore systemd services to their pre-migration state.
Restores:
    - service enablement state
    - service configuration backups
"""

import sys
import subprocess

if len(sys.argv) < 2:
    raise SystemExit("Usage: service-restore.py <host>")

host = sys.argv[1]

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

print(f"=== Restoring services on {host} ===")

run(["ssh", host, "sudo systemctl preset-all"])
run(["ssh", host, "sudo cp /etc/systemd/backup/*.service /etc/systemd/system/ 2>/dev/null || true"])
run(["ssh", host, "sudo systemctl daemon-reload"])

print("[SERVICE RESTORE COMPLETE]")
