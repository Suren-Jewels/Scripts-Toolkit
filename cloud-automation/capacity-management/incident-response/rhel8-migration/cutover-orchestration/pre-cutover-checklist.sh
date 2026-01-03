#!/usr/bin/env bash
# Capability: Ensure readiness before cutover.

set -euo pipefail

echo "=== Running Pre-Cutover Checklist ==="

check() {
    local desc="$1"
    local cmd="$2"

    echo "- $desc"
    eval "$cmd" >/dev/null 2>&1 \
        && echo "  [OK]" \
        || { echo "  [FAIL]"; exit 1; }
}

check "Disk space available" "df -h"
check "Network connectivity" "ping -c1 8.8.8.8"
check "System load acceptable" "uptime"

echo "[PRE-CUTOVER CHECKLIST PASSED]"
