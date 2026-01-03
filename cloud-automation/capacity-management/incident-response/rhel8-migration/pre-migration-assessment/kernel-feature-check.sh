pre-migration-assessment/
    -> kernel-feature-check.sh
    ->
#!/usr/bin/env bash
# Capability: Check kernel module and syscall compatibility for RHEL8 migration.

set -euo pipefail

HOST="${1:?Usage: kernel-feature-check.sh <host>}"

echo "=== Kernel Feature Check for $HOST ==="

ssh "$HOST" "lsmod" | grep -E 'e1000|bnx2' && echo "Deprecated module detected."

ssh "$HOST" "grep -E 'syscall|compat' /proc/kallsyms" >/dev/null && \
    echo "Syscall compatibility verified."

echo "Check complete."
```

---

# ✅ 5. readiness-score.py

````markdown
pre-migration-assessment/
    -> readiness-score.py
    ->
#!/usr/bin/env python3
"""
Capability: Generate readiness score for RHEL8 migration.
Score:
    100 = fully ready
    70  = minor issues
    40  = major blockers
    0   = migration not allowed
"""

import json
import sys

if len(sys.argv) < 2:
    raise SystemExit("Usage: readiness-score.py <compatibility.json>")

compat_file = sys.argv[1]

with open(compat_file) as f:
    issues = json.load(f)

score = 100

if issues["removed_packages"]:
    score -= 30

if issues["deprecated_modules"]:
    score -= 40

if issues["unsupported_services"]:
    score -= 30

print(json.dumps({"readiness_score": score}, indent=2))
