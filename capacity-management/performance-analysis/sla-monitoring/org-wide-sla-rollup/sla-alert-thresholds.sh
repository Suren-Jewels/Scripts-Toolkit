#!/usr/bin/env bash
set -euo pipefail

# sla-alert-thresholds.sh
# Wrapper around threshold-evaluator.py to produce alert-ready output.

ROLLUP_FILE="${ROLLUP_FILE:-}"
THRESHOLDS_FILE="${THRESHOLDS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-sla-alerts.json}"

if [[ -z "${ROLLUP_FILE}" ]]; then
  echo "ERROR: ROLLUP_FILE is required." >&2
  exit 1
fi

if [[ -z "${THRESHOLDS_FILE}" ]]; then
  echo "ERROR: THRESHOLDS_FILE is required." >&2
  exit 1
fi

if [[ ! -f "${ROLLUP_FILE}" ]]; then
  echo "ERROR: Rollup file not found: ${ROLLUP_FILE}" >&2
  exit 1
fi

if [[ ! -f "${THRESHOLDS_FILE}" ]]; then
  echo "ERROR: Thresholds file not found: ${THRESHOLDS_FILE}" >&2
  exit 1
fi

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

TMP_EVAL="__threshold_eval_tmp.json"

export SLA_ROLLUP_FILE="${ROLLUP_FILE}"
export THRESHOLDS_FILE="${THRESHOLDS_FILE}"
export OUTPUT_FILE="${TMP_EVAL}"

python3 "$(dirname "$0")/threshold-evaluator.py"

latency_ok=$(jq -r '.results.latency_within_threshold' "${TMP_EVAL}")
error_ok=$(jq -r '.results.error_rate_within_threshold' "${TMP_EVAL}")
uptime_ok=$(jq -r '.results.uptime_within_threshold' "${TMP_EVAL}")
score_ok=$(jq -r '.results.sla_score_within_threshold' "${TMP_EVAL}")

alert=false
if [[ "${latency_ok}" != "true" ]] || \
   [[ "${error_ok}" != "true" ]] || \
   [[ "${uptime_ok}" != "true" ]] || \
   [[ "${score_ok}" != "true" ]]; then
    alert=true
fi

cat <<EOF > "${OUTPUT_FILE}"
{
  "meta": {
    "collector": "sla-alert-thresholds.sh",
    "generated_at_utc": "$(timestamp_utc)"
  },
  "alert": ${alert},
  "threshold_evaluation": $(cat "${TMP_EVAL}")
}
EOF

rm -f "${TMP_EVAL}"

if [[ "${alert}" == "true" ]]; then
  exit 2
fi

exit 0
