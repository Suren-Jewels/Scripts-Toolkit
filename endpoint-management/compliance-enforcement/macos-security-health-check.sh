#!/bin/bash
#
# macos-security-health-check.sh
# Location: endpoint-management/compliance-enforcement/macos-security-health-check.sh
#
# Author: Suren Jewels
#
# DESCRIPTION:
#   A professional, sanitized macOS security & compliance health check script.
#   This script is designed for enterprise environments and FixWare field use.
#
#   It performs:
#     - FileVault status check
#     - Firewall status check
#     - Gatekeeper status check
#     - Password policy validation
#     - MDM enrollment check (generic, not vendor-specific)
#     - EDR agent presence check (generic)
#
#   No IL4/IL5, Jamf, or CrowdStrike identifiers are included.
#   All checks are generic and safe for public portfolios.
#
# USAGE:
#     sudo ./macos-security-health-check.sh
#
# EXIT CODES:
#     0 = All checks passed
#     1 = One or more checks failed
#

LOG_PREFIX="[FixWare-MacOS-Check]"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $LOG_PREFIX $1"
}

failures=0

# -----------------------------
# FileVault Check
# -----------------------------
log "Checking FileVault encryption status..."
fv_status=$(fdesetup status)

if echo "$fv_status" | grep -q "FileVault is On"; then
    log "PASS: FileVault is enabled."
else
    log "FAIL: FileVault is NOT enabled."
    failures=$((failures+1))
fi

# -----------------------------
# Firewall Check
# -----------------------------
log "Checking Firewall status..."
fw_status=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null)

if [ "$fw_status" == "1" ] || [ "$fw_status" == "2" ]; then
    log "PASS: Firewall is enabled."
else
    log "FAIL: Firewall is NOT enabled."
    failures=$((failures+1))
fi

# -----------------------------
# Gatekeeper Check
# -----------------------------
log "Checking Gatekeeper status..."
gk_status=$(spctl --status 2>/dev/null)

if echo "$gk_status" | grep -q "assessments enabled"; then
    log "PASS: Gatekeeper is enabled."
else
    log "FAIL: Gatekeeper is NOT enabled."
    failures=$((failures+1))
fi

# -----------------------------
# Password Policy Check
# -----------------------------
log "Checking password policy..."
pw_policy=$(pwpolicy getaccountpolicies 2>/dev/null)

if echo "$pw_policy" | grep -q "policyCategory"; then
    log "PASS: Password policy is configured."
else
    log "FAIL: Password policy is NOT configured."
    failures=$((failures+1))
fi

# -----------------------------
# MDM Enrollment Check (Generic)
# -----------------------------
log "Checking MDM enrollment..."
mdm_status=$(profiles status -type enrollment 2>/dev/null)

if echo "$mdm_status" | grep -q "Enrolled via MDM"; then
    log "PASS: Device is enrolled in MDM."
else
    log "FAIL: Device is NOT enrolled in MDM."
    failures=$((failures+1))
fi

# -----------------------------
# EDR Agent Check (Generic)
# -----------------------------
log "Checking for EDR agent..."
# Generic check for common EDR directories (no vendor names)
edr_paths=(
    "/Applications/EndpointSecurity.app"
    "/Library/EndpointSecurity"
    "/usr/local/bin/endpoint-agent"
)

edr_found=false
for path in "${edr_paths[@]}"; do
    if [ -e "$path" ]; then
        edr_found=true
        break
    fi
done

if [ "$edr_found" = true ]; then
    log "PASS: EDR agent detected."
else
    log "FAIL: No EDR agent detected."
    failures=$((failures+1))
fi

# -----------------------------
# Final Result
# -----------------------------
if [ "$failures" -eq 0 ]; then
    log "All macOS security checks PASSED."
    exit 0
else
    log "One or more macOS security checks FAILED. Total failures: $failures"
    exit 1
fi
