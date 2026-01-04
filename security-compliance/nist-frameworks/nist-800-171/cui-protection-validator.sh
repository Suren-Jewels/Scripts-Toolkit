#!/usr/bin/env bash
# CUI Protection Validator
#
# Validates basic CUI protection controls such as:
# - Encryption at rest configuration
# - Encryption in transit (TLS) configuration
# - Access control (group ownership / file permissions)
#
# Uses a JSON configuration file describing expected state.
#
# Example JSON:
# {
#   "cui_paths": [
#     { "path": "/secure/cui", "owner_group": "cui-handlers", "mode": "750" }
#   ],
#   "tls_config_file": "/etc/nginx/nginx.conf",
#   "encryption_required": true
# }
#
# Requirements:
# - jq installed for JSON parsing
#
# NOTE: This is a synthetic, generic example; real CUI validation will
#       depend on environment and policy specifics.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME --config <cui-config.json> [--debug]

Required:
  --config   Path to JSON file describing CUI protection configuration.

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

log_info "Validating CUI protection using config: $CONFIG_FILE"

CUI_PATHS_JSON=$(jq -c '.cui_paths // []' "$CONFIG_FILE")
TLS_CONFIG_FILE=$(jq -r '.tls_config_file // ""' "$CONFIG_FILE")
ENCRYPTION_REQUIRED=$(jq -r '.encryption_required // "true"' "$CONFIG_FILE")

failures=0

# Validate CUI directory ownership and mode
echo "$CUI_PATHS_JSON" | jq -c '.[]' | while read -r entry; do
    path=$(echo "$entry" | jq -r '.path // ""')
    owner_group=$(echo "$entry" | jq -r '.owner_group // ""')
    mode_expected=$(echo "$entry" | jq -r '.mode // ""')

    if [[ -z "$path" ]]; then
        log_warn "CUI path entry missing 'path'. Skipping."
        continue
    fi

    if [[ ! -e "$path" ]]; then
        log_warn "CUI path does not exist: $path"
        failures=$((failures+1))
        continue
    fi

    # Check group ownership if provided
    if [[ -n "$owner_group" ]]; then
        group_actual=$(stat -c "%G" "$path" 2>/dev/null || echo "UNKNOWN")
        if [[ "$group_actual" != "$owner_group" ]]; then
            log_warn "Path $path group mismatch: expected '$owner_group', got '$group_actual'"
            failures=$((failures+1))
        else
            log_info "Path $path group ownership OK: $group_actual"
        fi
    fi

    # Check permissions if provided
    if [[ -n "$mode_expected" ]]; then
        mode_actual=$(stat -c "%a" "$path" 2>/dev/null || echo "UNKNOWN")
        if [[ "$mode_actual" != "$mode_expected" ]]; then
            log_warn "Path $path mode mismatch: expected '$mode_expected', got '$mode_actual'"
            failures=$((failures+1))
        else
            log_info "Path $path mode OK: $mode_actual"
        fi
    fi
done

# Validate TLS configuration file existence (synthetic check)
if [[ -n "$TLS_CONFIG_FILE" ]]; then
    if [[ -f "$TLS_CONFIG_FILE" ]]; then
        log_info "TLS configuration file present: $TLS_CONFIG_FILE"
    else
        log_warn "TLS configuration file missing: $TLS_CONFIG_FILE"
        failures=$((failures+1))
    fi
fi

# Encryption required flag (high-level, synthetic)
if [[ "$ENCRYPTION_REQUIRED" != "true" && "$ENCRYPTION_REQUIRED" != "false" ]]; then
    log_warn "Invalid value for encryption_required in config: $ENCRYPTION_REQUIRED"
    failures=$((failures+1))
else
    log_info "Encryption required flag: $ENCRYPTION_REQUIRED"
fi

log_info "CUI protection validation complete."

if [[ "$failures" -gt 0 ]]; then
    log_warn "CUI protection validation completed with $failures issue(s)."
    exit 2
else
    log_info "All CUI protection checks passed."
    exit 0
fi
