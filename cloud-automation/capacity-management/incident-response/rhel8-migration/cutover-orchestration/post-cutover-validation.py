#!/usr/bin/env python3
# Capability: Validate system health after cutover.

import subprocess
import json

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()

health = {
    "system_running": run(["systemctl", "is-system-running"]),
    "failed_services": run(["systemctl", "--failed", "--no-legend", "--plain"]),
    "network_status": run(["ping", "-c1", "8.8.8.8"])
}

print(json.dumps(health, indent=2))
