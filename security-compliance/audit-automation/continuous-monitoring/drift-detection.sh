#!/usr/bin/env bash
#
# drift-detection.sh
#
# Configuration drift detection utility.
#
# Responsibilities:
# - Compare current system or infrastructure configuration against a known baseline
# - Highlight differences in a machine-readable format (JSON)
# - Provide exit codes suitable for CI/CD or monitoring pipelines
#
# Notes:
# - Baseline and current state are passed as files or directories.
# - No credentials or secrets are read or written by this script.

set -o errexit
set -o pipefail
set -o nounset

# -----------------------------
# Logging helpers
# -----------------------------

log() {
  # Basic logger with timestamp.
  local level="$1"
  shift
  local message="$*"
  # shellcheck disable=SC2155
  local ts
  ts="$(date --iso-8601=seconds 2>/dev/null || date)"
  printf "%s | drift_detection | %s | %s\n" "$ts" "$level" "$message" >&2
}

fatal() {
  log "ERROR" "$*"
  exit 1
}

# -----------------------------
# Usage
# -----------------------------

usage() {
  cat <<'EOF'
drift-detection.sh

Detect configuration drift between a baseline and current state.

Usage:
  drift-detection.sh \
    --baseline PATH \
    --current PATH \
    [--output PATH|stdout] \
    [--context LABEL]

Options:
  --baseline PATH   Baseline configuration file or directory.
  --current PATH    Current configuration file or directory.
  --output DEST     "stdout" (default) or a path to write JSON diff.
  --context LABEL   Context label (e.g., "prod", "staging") added to JSON output.
  -h, --help        Show this help message.

Exit codes:
  0  No drift detected.
  1  Usage or runtime error.
  2  Drift detected.
EOF
}

# -----------------------------
# Argument parsing
# -----------------------------

parse_args() {
  BASELINE=""
  CURRENT=""
  OUTPUT="stdout"
  CONTEXT=""

  local arg
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
      --baseline)
        shift || fatal "Missing value for --baseline"
        BASELINE="$1"
        ;;
      --current)
        shift || fatal "Missing value for --current"
        CURRENT="$1"
        ;;
      --output)
        shift || fatal "Missing value for --output"
        OUTPUT="$1"
        ;;
      --context)
        shift || fatal "Missing value for --context"
        CONTEXT="$1"
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

  if [[ -z "$BASELINE" || -z "$CURRENT" ]]; then
    usage
    fatal "Both --baseline and --current must be specified."
  fi
}

# -----------------------------
# Diff helpers
# -----------------------------

ensure_paths_valid() {
  [[ -e "$BASELINE" ]] || fatal "Baseline path does not exist: $BASELINE"
  [[ -e "$CURRENT"  ]] || fatal "Current path does not exist: $CURRENT"
}

run_diff() {
  # Perform a recursive, unified diff between baseline and current.
  # We ignore file metadata and focus on content differences.
  # The output is captured for JSON encoding.
  local diff_output
  if [[ -d "$BASELINE" && -d "$CURRENT" ]]; then
    diff_output="$(diff -ruN "$BASELINE" "$CURRENT" || true)"
  else
    diff_output="$(diff -u "$BASELINE" "$CURRENT" || true)"
  fi

  echo "$diff_output"
}

encode_diff_as_json() {
  # Encode the diff output as JSON for downstream systems.
  local diff_output="$1"

  # Use jq if available for robust JSON escaping.
  local json
  if command -v jq >/dev/null 2>&1; then
    json="$(jq -c -n \
      --arg baseline "$BASELINE" \
      --arg current "$CURRENT" \
      --arg context "$CONTEXT" \
      --arg diff "$diff_output" \
      '{
        baseline: $baseline,
        current: $current,
        context: $context,
        drift_detected: ($diff != ""),
        diff: $diff
      }' 2>/dev/null || true)"
  else
    # Fallback: naive JSON encoding with minimal escaping.
    local escaped_diff
    escaped_diff="$(printf '%s' "$diff_output" | sed 's/"/\\"/g')"
    json="{\"baseline\":\"$BASELINE\",\"current\":\"$CURRENT\",\"context\":\"$CONTEXT\",\"drift_detected\":$( [[ -n "$diff_output" ]] && echo true || echo false ),\"diff\":\"$escaped_diff\"}"
  fi

  printf '%s\n' "$json"
}

write_output() {
  local payload="$1"
  if [[ "$OUTPUT" == "stdout" ]]; then
    printf '%s\n' "$payload"
  else
    printf '%s\n' "$payload" >"$OUTPUT"
  fi
}

# -----------------------------
# Main
# -----------------------------

main() {
  parse_args "$@"
  ensure_paths_valid

  log "INFO" "Starting drift detection. baseline=$BASELINE current=$CURRENT context=$CONTEXT"

  local diff_output
  diff_output="$(run_diff)"

  local json_payload
  json_payload="$(encode_diff_as_json "$diff_output")"

  write_output "$json_payload"

  if [[ -n "$diff_output" ]]; then
    log "WARN" "Drift detected between baseline and current."
    # Exit code 2 specifically signifies drift detected.
    exit 2
  else
    log "INFO" "No configuration drift detected."
    exit 0
  fi
}

main "$@"
