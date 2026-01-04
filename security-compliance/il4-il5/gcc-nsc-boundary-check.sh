#!/usr/bin/env bash
# GCC/NSC Boundary Checker
# Validates that configured tenants/endpoints are restricted to GCC / GCC High / DoD / NSC boundaries.

set -euo pipefail

CONFIG_FILE="tenants.json"

usage() {
    echo "Usage: $0 --config <tenants.json>"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config) CONFIG_FILE="$2"; shift 2 ;;
        *) usage ;;
    esac
done

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "[INFO] Validating GCC/NSC boundaries using $CONFIG_FILE"

INVALID_COUNT=0

# Expected fields: tenant_name, cloud_type (GCC, GCC_HIGH, DOD, NSC), endpoint
jq -c '.tenants[]' "$CONFIG_FILE" | while read -r tenant; do
    NAME=$(echo "$tenant" | jq -r '.tenant_name')
    CLOUD=$(echo "$tenant" | jq -r '.cloud_type')
    ENDPOINT=$(echo "$tenant" | jq -r '.endpoint')

    case "$CLOUD" in
        "GCC"|"GCC_HIGH"|"DOD"|"NSC")
            echo "[OK] $NAME ($CLOUD) → $ENDPOINT"
            ;;
        *)
            echo "[WARN] $NAME has unsupported cloud_type: $CLOUD"
            INVALID_COUNT=$((INVALID_COUNT+1))
            ;;
    esac
done

if [[ "${INVALID_COUNT:-0}" -gt 0 ]]; then
    echo "[RESULT] Boundary check completed with WARNINGS ($INVALID_COUNT invalid entries)."
    exit 2
else
    echo "[RESULT] Boundary check passed for all tenants."
fi
