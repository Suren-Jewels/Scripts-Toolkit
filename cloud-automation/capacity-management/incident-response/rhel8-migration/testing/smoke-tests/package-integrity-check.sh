#!/usr/bin/env bash
# Capability: Validate RPM database integrity.

set -euo pipefail

echo "=== Running Package Integrity Check ==="

echo "[1/2] Checking RPM database..."
rpm --verify --all >/tmp/rpm-verify.log 2>&1 || true

if grep -qv "^$" /tmp/rpm-verify.log; then
    echo "  [FAIL] Package integrity issues detected"
    echo "  See /tmp/rpm-verify.log for details"
    exit 1
else
    echo "  [OK] RPM database clean"
fi

echo "[2/2] Checking for missing dependencies..."
rpm -Va --nofiles --nodigest >/tmp/rpm-deps.log 2>&1 || true

if grep -qv "^$" /tmp/rpm-deps.log; then
    echo "  [FAIL] Missing dependencies detected"
    echo "  See /tmp/rpm-deps.log for details"
    exit 1
else
    echo "  [OK] No missing dependencies"
fi

echo "[PACKAGE INTEGRITY CHECK PASSED]"
