#!/usr/bin/env bash
# select-controls.sh
#
# Control Selection based on baseline for RMF Step 2 (Select).
#
# This script:
# - Reads a YAML or JSON baseline definition
# - Filters controls by impact level (LOW, MODERATE, HIGH)
# - Prints selected controls for use in RMF documentation and tooling
#
# Example baseline YAML (synthetic):
# baselines:
#   LOW:
#     controls: ["AC-1", "AC-2"]
#   MODERATE:
#     controls: ["AC-1", "AC-2", "AC-3"]
#   HIGH:
#     controls: ["AC-1", "AC-2", "AC-3", "AC-6"]
#
# Requirements:
# - yq or jq, depending on config format
#
# NOTE:
# This is a synthetic helper; actual control selection should align
# with NIST guidance and organizational overlays.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME --baseline-file <file> --impact-level <LOW|MODERATE|HIGH> [--format yaml|json] [--debug]

Required:
  --baseline-file   Path to baseline definition (YAML or JSON).
  --impact-level    Impact level: LOW, MODERATE, or HIGH.

Options:
  --format          File format: yaml (default) or json.
  --debug           Enable verbose debug output.

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

BASELINE_FILE=""
IMPACT_LEVEL=""
FORMAT="yaml"
DEBUG=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --baseline-file)
            BASELINE_FILE="$2"
            shift 2
            ;;
        --impact-level)
            IMPACT_LEVEL="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
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

if [[ -z "$BASELINE_FILE" || -z "$IMPACT_LEVEL" ]]; then
    log_error "Missing required arguments."
    usage
fi

if [[ ! -f "$BASELINE_FILE" ]]; then
    log_error "Baseline file not found: $BASELINE_FILE"
    exit 1
fi

IMPACT_UPPER=$(echo "$IMPACT_LEVEL" | tr '[:lower:]' '[:upper:]')
case "$IMPACT_UPPER" in
    LOW|MODERATE|HIGH) ;;
    *)
        log_error "Invalid impact level: $IMPACT_LEVEL (use LOW, MODERATE, or HIGH)."
        exit 1
        ;;
esac

"$DEBUG" && set -x

log_info "Selecting controls for impact level: $IMPACT_UPPER"
log_info "Using baseline file: $BASELINE_FILE (format: $FORMAT)"

if [[ "$FORMAT" == "yaml" ]]; then
    if ! command -v yq >/dev/null 2>&1; then
        log_error "yq is required for YAML parsing but is not installed."
        exit 1
    fi
    # Extract controls list for the given baseline
    CONTROLS=$(yq -r ".baselines.$IMPACT_UPPER.controls[]" "$BASELINE_FILE" 2>/dev/null || true)
elif [[ "$FORMAT" == "json" ]]; then
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is required for JSON parsing but is not installed."
        exit 1
    fi
    CONTROLS=$(jq -r ".baselines.\"$IMPACT_UPPER\".controls[]" "$BASELINE_FILE" 2>/dev/null || true)
else
    log_error "Unsupported format: $FORMAT (use yaml or json)."
    exit 1
fi

if [[ -z "$CONTROLS" ]]; then
    log_warn "No controls found for impact level: $IMPACT_UPPER"
    exit 2
fi

echo "[RESULT] Selected Controls for Impact Level: $IMPACT_UPPER"
echo "$CONTROLS" | while read -r ctrl; do
    [[ -z "$ctrl" ]] && continue
    echo " - $ctrl"
done

exit 0
