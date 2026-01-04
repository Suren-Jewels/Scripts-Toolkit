#!/usr/bin/env bash
# finding-aging-report.sh
#
# Reports on overdue audit findings based on age and due date.
#
# Requirements:
# - bash
# - jq (for JSON processing)
#
# This script:
# - Reads a JSON file of findings (compatible with finding-tracker.py output)
# - Calculates age in days since created_at
# - Flags overdue findings based on due_date and optional severity-specific SLAs
# - Outputs a summary table and optional JSON report

set -euo pipefail

# -------------------------
# Default configuration
# -------------------------

DEFAULT_SLA_LOW=90
DEFAULT_SLA_MEDIUM=60
DEFAULT_SLA_HIGH=30
DEFAULT_SLA_CRITICAL=15

LOG_LEVEL="INFO"

# -------------------------
# Logging helpers
# -------------------------

log() {
  # Simple log function with levels: DEBUG, INFO, WARNING, ERROR
  local level="$1"; shift
  local message="$*"

  # Map log level to numeric value for filtering
  declare -A LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
  )

  local current_level="${LEVELS[$LOG_LEVEL]}"
  local msg_level="${LEVELS[$level]}"

  if [[ -z "${current_level:-}" || -z "${msg_level:-}" ]]; then
    # Fallback: always log if levels are not correctly defined
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [$level] $message" >&2
    return
  fi

  if (( msg_level >= current_level )); then
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [$level] $message" >&2
  fi
}

# -------------------------
# Usage
# -------------------------

usage() {
  cat <<EOF
Usage: $0 --input FILE [--output-json FILE] [--max-age DAYS] [--log-level LEVEL]

Options:
  --input FILE         Path to findings JSON file (required).
  --output-json FILE   Optional path to write detailed JSON aging report.
  --max-age DAYS       Only show findings older than this many days.
  --log-level LEVEL    Log level: DEBUG, INFO, WARNING, ERROR (default: INFO).

SLA overrides (optional, per severity):
  --sla-low DAYS
  --sla-medium DAYS
  --sla-high DAYS
  --sla-critical DAYS

Notes:
  - This script expects fields: id, title, severity, created_at, due_date (optional).
  - Uses jq for JSON parsing; please ensure jq is installed and on PATH.
EOF
}

# -------------------------
# Argument parsing
# -------------------------

INPUT_FILE=""
OUTPUT_JSON=""
MAX_AGE_DAYS=""

SLA_LOW="$DEFAULT_SLA_LOW"
SLA_MEDIUM="$DEFAULT_SLA_MEDIUM"
SLA_HIGH="$DEFAULT_SLA_HIGH"
SLA_CRITICAL="$DEFAULT_SLA_CRITICAL"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT_FILE="${2:-}"
      shift 2
      ;;
    --output-json)
      OUTPUT_JSON="${2:-}"
      shift 2
      ;;
    --max-age)
      MAX_AGE_DAYS="${2:-}"
      shift 2
      ;;
    --sla-low)
      SLA_LOW="${2:-}"
      shift 2
      ;;
    --sla-medium)
      SLA_MEDIUM="${2:-}"
      shift 2
      ;;
    --sla-high)
      SLA_HIGH="${2:-}"
      shift 2
      ;;
    --sla-critical)
      SLA_CRITICAL="${2:-}"
      shift 2
      ;;
    --log-level)
      LOG_LEVEL="${2:-INFO}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# -------------------------
# Validation
# -------------------------

if [[ -z "$INPUT_FILE" ]]; then
  echo "Error: --input is required." >&2
  usage
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file '$INPUT_FILE' does not exist." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' command is required but not found on PATH." >&2
  exit 1
fi

log "INFO" "Using input file: $INPUT_FILE"

# -------------------------
# Date helpers
# -------------------------

# Convert ISO date or datetime to epoch seconds (UTC)
iso_to_epoch() {
  local iso="$1"
  # Rely on GNU date; for portability you may adapt this function
  date -u -d "$iso" +"%s"
}

# Calculate difference in days between now and an ISO timestamp
age_in_days() {
  local iso="$1"
  local now_epoch
  local ts_epoch

  now_epoch="$(date -u +"%s")"
  ts_epoch="$(iso_to_epoch "$iso")"

  # Protect against invalid dates
  if [[ -z "$ts_epoch" ]]; then
    echo "0"
    return
  fi

  local diff=$(( (now_epoch - ts_epoch) / 86400 ))
  echo "$diff"
}

# Determine SLA days based on severity
sla_for_severity() {
  local severity="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
  case "$severity" in
    LOW) echo "$SLA_LOW" ;;
    MEDIUM) echo "$SLA_MEDIUM" ;;
    HIGH) echo "$SLA_HIGH" ;;
    CRITICAL) echo "$SLA_CRITICAL" ;;
    *) echo "$SLA_MEDIUM" ;;
  esac
}

# -------------------------
# Processing
# -------------------------

# Build JSON report using jq; we add age and overdue flags as fields
log "DEBUG" "Calculating aging details with jq."

REPORT_JSON="$(jq -c '
  map(
    . as $f |
    .created_at as $created
    | (if ($created == null or $created == "") then null else $created end) as $created_norm
    | .severity as $severity
    | .due_date as $due
    | .id as $id
    | .title as $title
    | {
        id: $id,
        title: $title,
        severity: $severity,
        created_at: $created_norm,
        due_date: $due
      }
  )
' "$INPUT_FILE")"

# Iterate with jq and bash to add dynamic metrics (age_in_days, sla_days, overdue)
FINAL_REPORT="[]"

# We use a temporary file to avoid issues with subshells
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

printf "%s" "$REPORT_JSON" > "$tmp_file"

index=0
total="$(jq 'length' "$tmp_file")"

while [[ "$index" -lt "$total" ]]; do
  item="$(jq -c ".[$index]" "$tmp_file")"
  created_at="$(echo "$item" | jq -r '.created_at // empty')"
  severity="$(echo "$item" | jq -r '.severity // "MEDIUM"')"
  id="$(echo "$item" | jq -r '.id')"

  if [[ -z "$created_at" || "$created_at" == "null" ]]; then
    age_days=0
  else
    age_days="$(age_in_days "$created_at" || echo "0")"
  fi

  sla_days="$(sla_for_severity "$severity")"

  # Determine overdue if:
  # - age exceeds SLA, OR
  # - due_date is set and now is past due_date
  due_date="$(echo "$item" | jq -r '.due_date // empty')"
  overdue="false"

  if [[ "$age_days" -gt "$sla_days" ]]; then
    overdue="true"
  fi

  if [[ -n "$due_date" && "$due_date" != "null" ]]; then
    now_epoch="$(date -u +"%s")"
    due_epoch="$(iso_to_epoch "$due_date" || echo "")"
    if [[ -n "$due_epoch" && "$now_epoch" -gt "$due_epoch" ]]; then
      overdue="true"
    fi
  fi

  log "DEBUG" "Finding $id age=$age_days days, SLA=$sla_days, overdue=$overdue"

  # Add calculated fields
  updated_item="$(echo "$item" | jq \
    --arg age_days "$age_days" \
    --arg sla_days "$sla_days" \
    --arg overdue "$overdue" \
    '
    .age_days = ($age_days | tonumber) |
    .sla_days = ($sla_days | tonumber) |
    .overdue = ($overdue == "true")
    ')"

  FINAL_REPORT="$(printf '%s\n%s' "$FINAL_REPORT" "$updated_item" | jq -s '.[0] + [.[1]]')"

  index=$((index + 1))
done

# Apply optional MAX_AGE filter for console output
FILTERED_REPORT="$FINAL_REPORT"
if [[ -n "${MAX_AGE_DAYS:-}" ]]; then
  FILTERED_REPORT="$(echo "$FINAL_REPORT" | jq --arg max "$MAX_AGE_DAYS" '
    map(select(.age_days >= ($max | tonumber)))
  ')"
  log "INFO" "Filtering findings to age >= $MAX_AGE_DAYS days."
fi

# -------------------------
# Console summary output
# -------------------------

echo "Finding Aging Report"
echo "Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Pretty table for console (ID, Severity, Age, SLA, Overdue)
echo "ID           | Severity | Age(d) | SLA(d) | Overdue | Title"
echo "-------------+----------+--------+--------+---------+------------------------------"

echo "$FILTERED_REPORT" | jq -r '
  .[] |
  [
    (.id | tostring),
    (.severity // "UNKNOWN"),
    (.age_days | tostring),
    (.sla_days | tostring),
    (if .overdue then "YES" else "NO" end),
    (.title // "")
  ] |
  @tsv
' | while IFS=$'\t' read -r id severity age sla overdue title; do
  printf "%-12s | %-8s | %6s | %6s | %-7s | %s\n" "$id" "$severity" "$age" "$sla" "$overdue" "$title"
done

# -------------------------
# Optional JSON output
# -------------------------

if [[ -n "$OUTPUT_JSON" ]]; then
  echo "$FINAL_REPORT" | jq '.' > "$OUTPUT_JSON"
  log "INFO" "Detailed JSON aging report written to $OUTPUT_JSON"
fi
