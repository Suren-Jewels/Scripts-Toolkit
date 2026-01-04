#!/usr/bin/env bash
#
# collect-logs.sh
# Centralized log collection script.
# - Collects logs from specified directories/files
# - Supports configurable output directory and time window
# - Writes a compressed archive for evidence
#

set -o errexit
set -o pipefail
set -o nounset

# -----------------------------
# Default configuration values
# -----------------------------

DEFAULT_CONFIG_FILE="./collect-logs.conf"
DEFAULT_OUTPUT_DIR="/var/tmp/evidence-logs"
DEFAULT_LOG_PATHS="/var/log"
DEFAULT_DAYS=7
DEFAULT_VERBOSE="false"

# -----------------------------
# Logging helpers
# -----------------------------

log_info() {
  printf '[INFO] %s\n' "$*" >&2
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

log_debug() {
  if [[ "${VERBOSE:-false}" == "true" ]]; then
    printf '[DEBUG] %s\n' "$*" >&2
  fi
}

# -----------------------------
# Usage
# -----------------------------

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -c, --config FILE         Path to config file (default: ${DEFAULT_CONFIG_FILE})
  -o, --output-dir DIR      Output directory for collected logs (default: ${DEFAULT_OUTPUT_DIR})
  -p, --paths PATHS         Comma-separated list of paths to collect logs from (default: ${DEFAULT_LOG_PATHS})
  -d, --days N              Collect logs modified in the last N days (default: ${DEFAULT_DAYS})
  -v, --verbose             Enable verbose debug logging
  -h, --help                Show this help message

Config file format (simple KEY=VALUE shell format):
  OUTPUT_DIR=/var/tmp/evidence-logs
  LOG_PATHS=/var/log,/opt/app/logs
  DAYS=7
  VERBOSE=false

EOF
}

# -----------------------------
# Config loading
# -----------------------------

load_config_file() {
  local config_file="$1"

  if [[ -f "${config_file}" ]]; then
    log_info "Loading configuration from ${config_file}"
    # shellcheck source=/dev/null
    source "${config_file}"
  else
    log_debug "Config file ${config_file} not found; using defaults/CLI arguments."
  fi
}

# -----------------------------
# Argument parsing
# -----------------------------

CONFIG_FILE="${DEFAULT_CONFIG_FILE}"
OUTPUT_DIR="${DEFAULT_OUTPUT_DIR}"
LOG_PATHS="${DEFAULT_LOG_PATHS}"
DAYS="${DEFAULT_DAYS}"
VERBOSE="${DEFAULT_VERBOSE}"

# Parse short and long options
PARSED_ARGS=$(getopt -o c:o:p:d:vh --long config:,output-dir:,paths:,days:,verbose,help -- "$@") || {
  log_error "Failed to parse arguments."
  usage
  exit 1
}
eval set -- "${PARSED_ARGS}"

while true; do
  case "$1" in
    -c|--config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    -o|--output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -p|--paths)
      LOG_PATHS="$2"
      shift 2
      ;;
    -d|--days)
      DAYS="$2"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Load config file (CLI args already set defaults; config can override them)
load_config_file "${CONFIG_FILE}"

# -----------------------------
# Validation
# -----------------------------

if ! [[ "${DAYS}" =~ ^[0-9]+$ ]]; then
  log_error "DAYS must be an integer (received: ${DAYS})"
  exit 1
fi

if [[ ! -d "${OUTPUT_DIR}" ]]; then
  log_info "Creating output directory: ${OUTPUT_DIR}"
  mkdir -p "${OUTPUT_DIR}" || {
    log_error "Failed to create output directory: ${OUTPUT_DIR}"
    exit 1
  }
fi

# -----------------------------
# Main collection function
# -----------------------------

collect_logs() {
  local timestamp archive_name tmp_dir
  timestamp=$(date +"%Y%m%d-%H%M%S")
  archive_name="logs-evidence-${timestamp}.tar.gz"
  tmp_dir="${OUTPUT_DIR}/logs-evidence-${timestamp}"

  log_info "Starting log collection..."
  log_debug "Using DAYS=${DAYS}, LOG_PATHS=${LOG_PATHS}, OUTPUT_DIR=${OUTPUT_DIR}"

  mkdir -p "${tmp_dir}"

  IFS=',' read -r -a paths_array <<< "${LOG_PATHS}"

  for path in "${paths_array[@]}"; do
    path=$(echo "${path}" | xargs)  # trim whitespace
    if [[ -z "${path}" ]]; then
      continue
    fi

    if [[ ! -e "${path}" ]]; then
      log_warn "Path does not exist, skipping: ${path}"
      continue
    fi

    log_info "Collecting logs from: ${path}"

    # Find files modified in the last N days; avoid following symlinks to reduce surprises
    # -type f : files only
    # -mtime -N : modified within N days
    # -print0 : safe for spaces/newlines in filenames
    while IFS= read -r -d '' file; do
      log_debug "Including file: ${file}"
      # Preserve relative path structure under tmp_dir
      rel_path=$(realpath --relative-to="/" "${file}" 2>/dev/null || echo "${file#/}")
      dest_dir="${tmp_dir}/$(dirname "${rel_path}")"
      mkdir -p "${dest_dir}"
      cp --preserve=mode,timestamps "${file}" "${dest_dir}/" || {
        log_warn "Failed to copy file: ${file}"
      }
    done < <(find "${path}" -type f -mtime "-${DAYS}" -print0 2>/dev/null || true)

  done

  log_info "Creating archive: ${archive_name}"
  (cd "${OUTPUT_DIR}" && tar -czf "${archive_name}" "$(basename "${tmp_dir}")") || {
    log_error "Failed to create archive."
    exit 1
  }

  log_info "Log evidence collection completed successfully."
  log_info "Archive location: ${OUTPUT_DIR}/${archive_name}"
}

# -----------------------------
# Entrypoint
# -----------------------------

collect_logs
