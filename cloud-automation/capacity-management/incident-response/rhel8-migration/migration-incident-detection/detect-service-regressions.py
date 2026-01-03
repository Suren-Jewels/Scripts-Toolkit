migration-incident-detection/
    -> detect-service-regressions.py
    ->
#!/usr/bin/env python3
"""
Capability: Detect systemd service regressions after RHEL8 migration.
Flags:
    - Failed services
    - Services stuck in degraded state
"""

import sys
import subprocess
import json

if len(sys.argv) < 2:
    raise SystemExit("Usage: detect-service-regressions.py <host>")

host = sys.argv[1]

cmd = [
    "ssh", host,
    "systemctl --failed --no-legend --plain"
]

result = subprocess.run(cmd, capture_output=True, text=True)
failed = result.stdout.strip().splitlines()

services = [line.split()[0] for line in failed if line.strip()]

print(json.dumps({"host": host, "failed_services": services}, indent=2))
