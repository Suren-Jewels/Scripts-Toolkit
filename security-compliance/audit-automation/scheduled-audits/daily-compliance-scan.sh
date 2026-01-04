#!/usr/bin/env bash
#
# daily-compliance-scan.sh
# Description:
#   Runs daily automated compliance checks based on a configuration file.
#   Designed to be invoked by cron or a scheduler.
#
# Usage:
#   ./daily-compliance-scan.sh -c /path/to/config.yaml -l /var/log/audit-automation/daily-compliance.log
#
# Exit codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - Config file not found or unreadable
#   3 - Required tool missing
#   4 - One or more checks failed
#

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_NAME="$(basename "$0")"

# --- Default values (can be overridden by arguments) ---
CONFIG_FILE=""
LOG_FILE="/var/log/audit-automation/daily-compliance.log"
DRY_RUN="false"

# --- Simple logger function with timestamp and level ---
log() {
    local level="$1"; shift
    local message="$*"
    local timestamp
    timestamp="$(date +"%Y-%m-%dT%H:%M:%S%z")"
    # Log to stdout and to log file (if writable)
    echo "${timestamp} [${SCRIPT_NAME}] [${level}] ${message}"
    if [[ -n "${LOG_FILE}" ]]; then
        # Use append redirection in subshell to prevent script exit on log failure
        {
            echo "${timestamp} [${SCRIPT_NAME}] [${level}] ${message}" >> "${LOG_FILE}" 2>/dev/null || true
        }
    fi
}

usage() {
    cat <<EOF
${SCRIPT_NAME} - Daily automated compliance checks.

Usage:
  ${SCRIPT_NAME} -c <config-file> [-l <log-file>] [--dry-run]

Options:
  -c, --config   Path to compliance configuration YAML (required)
  -l, --log      Path to log file (default: ${LOG_FILE})
      --dry-run  Show what would be executed without running checks
  -h, --help     Show this help message and exit
EOF
}

# --- Parse arguments ---
parse_args() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
    done

    if [[ -z "${CONFIG_FILE}" ]]; then
        log "ERROR" "Missing required argument: --config"
        usage
        exit 1
    fi
}

# --- Validate prerequisites and files ---
validate_environment() {
    # Validate config file
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log "ERROR" "Config file not found: ${CONFIG_FILE}"
        exit 2
    fi
    if [[ ! -r "${CONFIG_FILE}" ]]; then
        log "ERROR" "Config file not readable: ${CONFIG_FILE}"
        exit 2
    fi

    # Ensure basic tools exist (extend as needed)
    local required_tools=("grep" "awk" "sed")
    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" >/dev/null 2>&1; then
            log "ERROR" "Required tool not found in PATH: ${tool}"
            exit 3
        fi
    done

    # Attempt to create log directory if needed
    local log_dir
    log_dir="$(dirname "${LOG_FILE}")"
    if [[ ! -d "${log_dir}" ]]; then
        mkdir -p "${log_dir}" 2>/dev/null || log "WARN" "Unable to create log directory: ${log_dir}"
    fi
}

# --- Example function: run a filesystem permission check ---
run_filesystem_check() {
    local path_pattern="$1"
    local expected_mode="$2"

    log "INFO" "Checking filesystem permissions for pattern='${path_pattern}' expected_mode='${expected_mode}'"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would validate permissions on: ${path_pattern}"
        return 0
    fi

    # Example: find files not matching expected mode
    # Real implementations should refine find predicates and handle large trees cautiously
    local non_compliant
    set +o errexit  # capture non-zero exit of find without exiting script
    non_compliant="$(find ${path_pattern} ! -perm "${expected_mode}" -type f 2>/dev/null || true)"
    set -o errexit

    if [[ -n "${non_compliant}" ]]; then
        log "ERROR" "Non-compliant permissions detected for pattern '${path_pattern}':"
        # Limit output to avoid excessively large logs; adjust as needed
        echo "${non_compliant}" | head -n 50 | while read -r line; do
            log "ERROR" " - ${line}"
        done
        return 1
    else
        log "INFO" "Filesystem permissions compliant for pattern='${path_pattern}'"
    fi
}

# --- Stub: parse config and run checks ---
run_compliance_checks() {
    log "INFO" "Starting compliance checks using config: ${CONFIG_FILE}"

    # In a real implementation, parse YAML (e.g., with yq or python)
    # For safety and portability, this script assumes a simple key=value format or
    # uses dedicated helper scripts. The block below illustrates how to
    # integrate with a YAML-aware tool without hardcoding credentials.

    # Example: if you have yq installed and config like:
    # checks:
    #   - type: filesystem
    #     path_pattern: "/etc/*.conf"
    #     expected_mode: "600"
    #
    # you could iterate with:
    #
    # mapfile -t fs_paths < <(yq '.checks[] | select(.type=="filesystem") | .path_pattern' "${CONFIG_FILE}")
    # mapfile -t fs_modes < <(yq '.checks[] | select(.type=="filesystem") | .expected_mode' "${CONFIG_FILE}")
    #
    # For now we simulate a single check driven by environment variables or defaults.

    local default_path_pattern="/etc/*.conf"
    local default_mode="600"

    # Allow overrides via environment for flexibility in CI/schedulers
    local path_pattern="${COMPLIANCE_FS_PATTERN:-$default_path_pattern}"
    local expected_mode="${COMPLIANCE_FS_MODE:-$default_mode}"

    local failures=0
    if ! run_filesystem_check "${path_pattern}" "${expected_mode}"; then
        failures=$((failures + 1))
    fi

    if [[ "${failures}" -gt 0 ]]; then
        log "ERROR" "Compliance checks completed with ${failures} failure(s)"
        return 1
    else
        log "INFO" "All compliance checks passed"
        return 0
    fi
}

main() {
    parse_args "$@"
    validate_environment

    log "INFO" "Starting ${SCRIPT_NAME} (dry-run=${DRY_RUN})"
    if run_compliance_checks; then
        log "INFO" "${SCRIPT_NAME} completed successfully"
        exit 0
    else
        log "ERROR" "${SCRIPT_NAME} completed with failures"
        exit 4
    fi
}

main "$@"
