#!/usr/bin/env bash
set -euo pipefail

# sla-rollup.sh

LATENCY_ANALYSIS_FILE="${LATENCY_ANALYSIS_FILE:-}"
ERROR_ANALYSIS_FILE="${ERROR_ANALYSIS_FILE:-}"
UPTIME_ANALYSIS_FILE="${UPTIME_ANALYSIS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-sla-rollup.json}"

if [[ -z "${LATENCY_ANALYSIS_FILE}" ]]; then
  echo "ERROR: LATENCY_ANALYSIS_FILE is required." >&2
  exit 1
fi

if [[ -z "${ERROR_ANALYSIS_FILE}" ]]; then
  echo "ERROR: ERROR_ANALYSIS_FILE is required." >&2
  exit 1
fi

if [[ -z "${UPTIME_ANALYSIS_FILE}" ]]; then
  echo "ERROR: UPTIME_ANALYSIS_FILE is required." >&2
  exit 1
fi

for f in "${LATENCY_ANALYSIS_FILE}" "${ERROR_ANALYSIS_FILE}" "${UPTIME_ANALYSIS_FILE}"; do
  if [[ ! -f "${f}" ]]; then
    echo "ERROR: File not found: ${f}" >&2
    exit 1
  fi
done

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

latency_json="$(cat "${LATENCY_ANALYSIS_FILE}")"
error_json="$(cat "${ERROR_ANALYSIS_FILE}")"
uptime_json="$(cat "${UPTIME_ANALYSIS_FILE}")"

latency_rate="$(echo "${latency_json}" | jq -r '.summary.p95_latency_ms')"
error_rate="$(echo "${error_json}" | jq -r '.summary.error_rate')"
uptime_rate="$(echo "${uptime_json}" | jq -r '.summary.success_rate')"

sla_score="null"
if [[ "${latency_rate}" != "null" ]] && [[ "${error_rate}" != "null" ]] && [[ "${uptime_rate}" != "null" ]]; then
  sla_score=$(awk -v l="${latency_rate}" -v e="${error_rate}" -v u="${uptime_rate}" \
    'BEGIN { printf "%.4f", (u * 0.5) + ((1 - e) * 0.3) + ((1 / (1 + l)) * 0.2) }')
fi

cat <<EOF > "${OUTPUT_FILE}"
{
  "meta": {
    "collector": "sla-rollup.sh",
    "generated_at_utc": "$(timestamp_utc)"
  },
  "inputs": {
    "latency_analysis_file": "${LATENCY_ANALYSIS_FILE}",
    "error_analysis_file": "${ERROR_ANALYSIS_FILE}",
    "uptime_analysis_file": "${UPTIME_ANALYSIS_FILE}"
  },
  "sla": {
    "p95_latency_ms": ${latency_rate},
    "error_rate": ${error_rate},
    "uptime_rate": ${uptime_rate},
    "sla_score": ${sla_score}
  }
}
EOF
