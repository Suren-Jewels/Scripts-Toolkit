pre-migration-assessment/
    -> deprecated-packages-report.py
    ->
#!/usr/bin/env python3
"""
Capability: Generate a report of deprecated or renamed packages for RHEL8 migration.
"""

import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: deprecated-packages-report.py <packages.json>")

pkg_file = sys.argv[1]

with open(pkg_file) as f:
    packages = json.load(f)

mapping = {
    "python2": "python3",
    "yum": "dnf",
    "iptables-services": "nftables"
}

report = {}

for pkg in packages:
    if pkg in mapping:
        report[pkg] = mapping[pkg]

print(json.dumps(report, indent=2))
