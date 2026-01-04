#!/usr/bin/env bash
# Continuous Monitoring Checker
# Validates FedRAMP Continuous Monitoring (ConMon) requirements:
# - Patch currency
# - Vulnerability scan recency
# - Log collection status
# - Control drift indicators

set -euo pipefail

usage() {
    echo "Usage: $0 --patch-level <days> --scan-report <file> --log-status <file>"
    exit 1
}

PATCH_DAYS=""
SCAN_REPORT=""
LOG_STATUS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --patch-level) PATCH_DAYS="$2"; shift 2 ;;
        --scan-report) SCAN_REPORT="$2"; shift 2 ;;
        --log-status) LOG_STATUS="$2"; shift 2 ;;
        *) usage ;;
    esac
done

if [[ -z "$PATCH_DAYS" || -z "$SCAN_REPORT" || -z "$LOG_STATUS" ]]; then
    usage
fi

echo "[INFO] Checking FedRAMP Continuous Monitoring requirements..."

# Patch currency check
if (( PATCH_DAYS > 30 )); then
    echo "[WARN] Patch level exceeds 30-day FedRAMP requirement: ${PATCH_DAYS} days"
else
    echo "[OK] Patch level within FedRAMP requirement: ${PATCH_DAYS} days"
fi

# Vulnerability scan recency
if [[ ! -f "$SCAN_REPORT" ]]; then
    echo "[ERROR] Scan report not found: $SCAN_REPORT"
    exit 1
fi

SCAN_AGE=$(jq -r '.scan_age_days' "$SCAN_REPORT")
if (( SCAN_AGE > 30 )); then
    echo "[WARN] Vulnerability scan older than 30 days: ${SCAN_AGE} days"
else
    echo "[OK] Vulnerability scan is current: ${SCAN_AGE} days"
fi

# Log collection status
if [[ ! -f "$LOG_STATUS" ]]; then
    echo "[ERROR] Log status file not found: $LOG_STATUS"
    exit 1
fi

LOG_OK=$(jq -r '.log_collection_active' "$LOG_STATUS")
if [[ "$LOG_OK" != "true" ]]; then
    echo "[WARN] Log collection is NOT active"
else
    echo "[OK] Log collection active"
fi

echo "[RESULT] Continuous Monitoring check complete."
