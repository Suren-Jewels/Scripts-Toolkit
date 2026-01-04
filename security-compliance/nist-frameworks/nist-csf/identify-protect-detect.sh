#!/usr/bin/env bash
# identify-protect-detect.sh
#
# Validates basic implementation status for NIST CSF core functions:
# - Identify
# - Protect
# - Detect
#
# Uses a simple JSON configuration file to describe expected artifacts.
#
# Example JSON:
# {
#   "identify": {
#     "asset_inventory_file": "/etc/assets.json"
#   },
#   "protect": {
#     "firewall_service": "ufw"
#   },
#   "detect": {
#     "log_service": "rsyslog"
#   }
# }
#
# Requirements:
# - jq for JSON parsing
#
# This is a synthetic, generic validation script intended for internal,
# automation-friendly checks rather than authoritative compliance proof.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME --config <csf-core-config.json> [--debug]

Required:
  --config   Path to JSON file describing expected Identify/Protect/Detect artifacts.

Options:
  --debug    Enable verbose debug output.

EOF
    exit 1
}

log_info() {
    echo "[INFO] $*"
}

log_warn() {
    echo "[WARN] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

DEBUG=false
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --debug)
            DEBUG=true
            shift 1
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$CONFIG_FILE" ]]; then
    log_error "Missing required argument: --config"
    usage
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    log_error "jq is required but not installed."
    exit 1
fi

"$DEBUG" && set -x

log_info "Starting CSF Identify/Protect/Detect validation using config: $CONFIG_FILE"

failures=0

# ---- Identify checks --------------------------------------------------------
identify_asset_file=$(jq -r '.identify.asset_inventory_file // ""' "$CONFIG_FILE")

if [[ -n "$identify_asset_file" ]]; then
    if [[ -f "$identify_asset_file" ]]; then
        log_info "[Identify] Asset inventory file present: $identify_asset_file"
    else
        log_warn "[Identify] Asset inventory file missing: $identify_asset_file"
        failures=$((failures+1))
    fi
else
    log_warn "[Identify] No asset_inventory_file specified in config."
fi

# ---- Protect checks ---------------------------------------------------------
protect_firewall_service=$(jq -r '.protect.firewall_service // ""' "$CONFIG_FILE")

if [[ -n "$protect_firewall_service" ]]; then
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet "$protect_firewall_service"; then
            log_info "[Protect] Firewall service active: $protect_firewall_service"
        else
            log_warn "[Protect] Firewall service not active: $protect_firewall_service"
            failures=$((failures+1))
        fi
    else
        log_warn "[Protect] systemctl not available; cannot validate firewall service."
    fi
else
    log_warn "[Protect] No firewall_service specified in config."
fi

# ---- Detect checks ----------------------------------------------------------
detect_log_service=$(jq -r '.detect.log_service // ""' "$CONFIG_FILE")

if [[ -n "$detect_log_service" ]]; then
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet "$detect_log_service"; then
            log_info "[Detect] Log service active: $detect_log_service"
        else
            log_warn "[Detect] Log service not active: $detect_log_service"
            failures=$((failures+1))
        fi
    else
        log_warn "[Detect] systemctl not available; cannot validate log service."
    fi
else
    log_warn "[Detect] No log_service specified in config."
fi

log_info "CSF Identify/Protect/Detect validation complete."

if [[ "$failures" -gt 0 ]]; then
    log_warn "Validation completed with $failures issue(s)."
    exit 2
else
    log_info "All configured Identify/Protect/Detect checks passed."
    exit 0
fi
