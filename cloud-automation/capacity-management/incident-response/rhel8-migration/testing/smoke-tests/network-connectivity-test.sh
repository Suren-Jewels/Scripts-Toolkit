#!/usr/bin/env bash
# Capability: Validate network stack functionality.

set -euo pipefail

echo "=== Running Network Connectivity Test ==="

echo "[1/3] Checking interface status..."
ip link show >/dev/null 2>&1 \
    && echo "  [OK] Interfaces detected" \
    || { echo "  [FAIL] No interfaces detected"; exit 1; }

echo "[2/3] Checking gateway reachability..."
ip route | grep default >/dev/null 2>&1 \
    && GW=$(ip route | awk '/default/ {print $3}') \
    || { echo "  [FAIL] No default gateway"; exit 1; }

ping -c1 "$GW" >/dev/null 2>&1 \
    && echo "  [OK] Gateway reachable" \
    || { echo "  [FAIL] Gateway unreachable"; exit 1; }

echo "[3/3] Checking external connectivity..."
curl -s https://www.redhat.com >/dev/null \
    && echo "  [OK] External connectivity verified" \
    || { echo "  [FAIL] External connectivity failed"; exit 1; }

echo "[NETWORK CONNECTIVITY TEST PASSED]"
