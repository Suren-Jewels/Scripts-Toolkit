pre-migration-assessment/
    -> compatibility-scanner.py
    ->
#!/usr/bin/env python3
"""
Capability: Detect RHEL7 → RHEL8 incompatibilities.
Checks:
    - Removed packages
    - Deprecated kernel modules
    - Unsupported services
"""

import sys
import json

if len(sys.argv) < 2:
    raise SystemExit("Usage: compatibility-scanner.py <inventory.json>")

inventory_file = sys.argv[1]

with open(inventory_file) as f:
    data = json.load(f)

removed_packages = ["python2", "iptables-services", "net-tools"]
deprecated_modules = ["e1000", "bnx2"]
unsupported_services = ["network", "iptables"]

issues = {
    "removed_packages": [],
    "deprecated_modules": [],
    "unsupported_services": []
}

for pkg in data.get("packages", []):
    if pkg in removed_packages:
        issues["removed_packages"].append(pkg)

for mod in data.get("kernel_modules", []):
    if mod in deprecated_modules:
        issues["deprecated_modules"].append(mod)

for svc in data.get("services", []):
    if svc in unsupported_services:
        issues["unsupported_services"].append(svc)

print(json.dumps(issues, indent=2))
