#!/usr/bin/env bash
#
# security-event-aggregator.sh
#
# Security event aggregation and correlation helper.
#
# Responsibilities:
# - Aggregate security-relevant events from multiple log sources
# - Normalize records to a common JSON schema
# - Optionally filter by time window or severity
# - Write aggregated stream to stdout or a destination file
#
# Notes:
# - No credentials are used or required in this script.
# - Designed to be executed via cron, systemd, or CI/CD jobs.

set -o errexit
set -o pipefail
set -o nounset

# -----------------------------
# Default configuration values
# -----------------------------

# Default log sources; these can be overridden via CLI flags.
DEFAULT_LOG_SOURCES=(
  "/var/log/auth.log"
  "/var/log/syslog"
)

# Default output channel; "stdout" or a file path.
DEFAULT_OUTPUT="stdout"

# Default minimum severity; log lines below this will be filtered out.
# This is an example textual severity, not system-enforced.
DEFAULT_MIN_SEVERITY="INFO"

# -----------------------------
# Helper: logging
# -----------------------------

log() {
  # Basic logger that prints timestamp and level.
  # Usage: log "INFO" "message"
  local level="$1"
  shift
  local message="$*"
  # shellcheck disable=SC2155
  local ts
  ts="$(date --iso-8601=seconds 2>/dev/null || date)"
  printf "%s | security_event_aggregator | %s | %s\n" "$ts" "$level" "$message" >&2
}

# -----------------------------
# Helper: error exit
# -----------------------------

fatal() {
  # Print an error message and exit with non-zero status.
  # Usage: fatal "message"
  log "ERROR" "$*"
  exit 1
}

# -----------------------------
# Usage helper
# -----------------------------

usage() {
  cat <<'EOF'
security-event-aggregator.sh

Aggregate security events from multiple log files and normalize them.

Usage:
  security-event-aggregator.sh [--source FILE ...] [--output PATH|stdout] [--min-severity LEVEL]

Options:
  --source FILE       Path to a log file to aggregate.
                      Can be specified multiple times. Defaults to:
                          /var/log/auth.log
                          /var/log/syslog
  --output DEST       "stdout" (default) or a file path to write JSON events.
  --min-severity LVL  Minimum severity text to include (INFO, WARN, ERROR, etc.).
  -h, --help          Show this help text.

Example:
  security-event-aggregator.sh \
    --source /var/log/auth.log \
    --source /var/log/syslog \
    --output aggregated-events.json
EOF
}

# -----------------------------
# Argument parsing
# -----------------------------

parse_args() {
  # Initialize from defaults.
  OUTPUT="$DEFAULT_OUTPUT"
  MIN_SEVERITY="$DEFAULT_MIN_SEVERITY"
  LOG_SOURCES=("${DEFAULT_LOG_SOURCES[@]}")

  # Parse positional and flag-based arguments.
  # We use a simple loop instead of getopts for clarity and flexibility.
  local arg
  LOG_SOURCES=()
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
      --source)
        shift || fatal "Missing value for --source"
        LOG_SOURCES+=("$1")
        ;;
      --output)
        shift || fatal "Missing value for --output"
        OUTPUT="$1"
        ;;
      --min-severity)
        shift || fatal "Missing value for --min-severity"
        MIN_SEVERITY="$1"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fatal "Unknown argument: $arg"
        ;;
    esac
    shift || true
  done

  if [[ "${#LOG_SOURCES[@]}" -eq 0 ]]; then
    fatal "At least one --source must be specified."
  fi
}

# -----------------------------
# Severity normalizer
# -----------------------------

normalize_severity() {
  # Convert an arbitrary severity token into a canonical text level.
  # This is a simple heuristic; adapt as needed.
  local token="$1"
  token="${token^^}"  # uppercase

  case "$token" in
    *CRIT*|*ALERT*|*EMERG*) echo "CRITICAL" ;;
    *ERR*|*FAIL*) echo "ERROR" ;;
    *WARN*) echo "WARN" ;;
    *INFO*) echo "INFO" ;;
    *DEBUG*|*TRACE*) echo "DEBUG" ;;
    *) echo "INFO" ;;
  esac
}

severity_rank() {
  # Map severity level to a numeric rank for comparison (higher is more severe).
  local level="$1"
  case "$level" in
    DEBUG) echo 0 ;;
    INFO) echo 1 ;;
    WARN) echo 2 ;;
    ERROR) echo 3 ;;
    CRITICAL) echo 4 ;;
    *) echo 1 ;; # default INFO
  esac
}

# -----------------------------
# Output helpers
# -----------------------------

write_event() {
  # Write a normalized JSON event either to stdout or to a file.
  local json="$1"
  if [[ "$OUTPUT" == "stdout" ]]; then
    printf '%s\n' "$json"
  else
    printf '%s\n' "$json" >>"$OUTPUT"
  fi
}

# -----------------------------
# Log processing
# -----------------------------

process_log_file() {
  # Process a single log file and emit normalized JSON events.
  # Each line is treated as a potential security event candidate.
  local file="$1"

  if [[ ! -f "$file" ]]; then
    log "WARN" "Skipping missing log file: $file"
    return
  fi

  log "INFO" "Processing log file: $file"

  # Read the file line by line.
  # shellcheck disable=SC2162
  while IFS= read -r line; do
    # Basic filtering: skip empty lines.
    [[ -z "$line" ]] && continue

    # Extract a naive severity token from the line for demonstration purposes.
    # In a real implementation, you would parse syslog format properly.
    local severity
    severity="$(normalize_severity "$line")"

    local severity_min_rank
    local severity_rank_value
    severity_min_rank="$(severity_rank "$MIN_SEVERITY")"
    severity_rank_value="$(severity_rank "$severity")"

    # Filter out events below the configured minimum severity.
    if (( severity_rank_value < severity_min_rank )); then
      continue
    fi

    # Use current timestamp as event time; production code might parse from line.
    local ts
    ts="$(date --iso-8601=seconds 2>/dev/null || date)"

    # Build JSON representation.
    # NOTE: No sensitive data should be placed here; this is pure log content.
    local json
    json="$(jq -c -n \
      --arg source "$file" \
      --arg severity "$severity" \
      --arg message "$line" \
      --arg timestamp "$ts" \
      '{
        source: $source,
        severity: $severity,
        message: $message,
        timestamp: $timestamp
      }' 2>/dev/null || true)"

    # If jq is not available, we fall back to a minimal manual JSON.
    if [[ -z "$json" ]]; then
      json="{\"source\":\"$file\",\"severity\":\"$severity\",\"message\":\"$(printf '%s' "$line" | sed 's/"/\\"/g')\",\"timestamp\":\"$ts\"}"
    fi

    write_event "$json"
  done <"$file"
}

# -----------------------------
# Main entrypoint
# -----------------------------

main() {
  # Parse arguments into global variables.
  parse_args "$@"

  # Validate jq dependency if present in PATH; otherwise we log a warning but continue.
  if ! command -v jq >/dev/null 2>&1; then
    log "WARN" "jq not found; falling back to simple JSON encoding."
  fi

  log "INFO" "Starting security event aggregation."
  log "DEBUG" "Output=$OUTPUT, MinSeverity=$MIN_SEVERITY, Sources=${LOG_SOURCES[*]}"

  # Truncate output file if not stdout to avoid unbounded growth across runs.
  if [[ "$OUTPUT" != "stdout" ]]; then
    : >"$OUTPUT" || fatal "Unable to write to output file: $OUTPUT"
  fi

  # Process each source file.
  local src
  for src in "${LOG_SOURCES[@]}"; do
    process_log_file "$src"
  done

  log "INFO" "Security event aggregation completed."
}

main "$@"
