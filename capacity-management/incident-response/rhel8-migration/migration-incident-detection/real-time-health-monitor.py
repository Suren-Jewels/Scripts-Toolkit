migration-incident-detection/
    -> real-time-health-monitor.py
    ->
#!/usr/bin/env python3
"""
Capability: Live health monitoring during migration window.
Monitors:
    - CPU load
    - Memory pressure
    - Systemd service failures
    - Network connectivity
"""

import subprocess
import time
import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: real-time-health-monitor.py <host>")

host = sys.argv[1]

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()

while True:
    cpu = run(["ssh", host, "cat /proc/loadavg"])
    mem = run(["ssh", host, "free -m"])
    failed = run(["ssh", host, "systemctl --failed --no-legend --plain"])
    ping = run(["ssh", host, "ping -c1 8.8.8.8 >/dev/null 2>&1 && echo OK || echo FAIL"])

    snapshot = {
        "cpu_load": cpu,
        "memory": mem,
        "failed_services": failed.splitlines(),
        "network_status": ping
    }

    print(json.dumps(snapshot, indent=2))
    time.sleep(10)
