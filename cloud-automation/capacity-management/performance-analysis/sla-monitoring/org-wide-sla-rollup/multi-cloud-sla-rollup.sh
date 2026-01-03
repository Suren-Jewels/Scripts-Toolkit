#!/usr/bin/env bash
set -euo pipefail

# multi-cloud-sla-rollup.sh
# Aggregates latency-analysis.json, error-rate-analysis.json, uptime-analysis.json
# into a unified multi-cloud SLA rollup.

LATENCY_ANALYSIS_FILE="${LATENCY_ANALYSIS_FILE:-}"
ERROR_ANALYSIS_FILE="${ERROR_ANALYSIS_FILE:-}"
UPTIME_ANALYSIS_FILE="${UPTIME_ANALYSIS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-multi-cloud-sla-rollup.json}"

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

latency_p95="$(jq -r '.summary.p95_latency_ms' "${LATENCY_ANALYSIS_FILE}")"
error_rate="$(jq -r '.summary.error_rate' "${ERROR_ANALYSIS_FILE}")"
uptime_rate="$(jq -r '.summary.success_rate' "${UPTIME_ANALYSIS_FILE}")"

sla_score=$(awk -v l="${latency_p95}" -v e="${error_rate}" -v u="${uptime_rate}" \
  'BEGIN { printf "%.4f", (u * 0.5) + ((1 - e) * 0.3) + ((1 / (1 + l)) * 0.2) }')

cat <<EOF > "${OUTPUT_FILE}"
{
  "meta": {
    "collector": "multi-cloud-sla-rollup.sh",
    "generated_at_utc": "$(timestamp_utc)"
  },
  "inputs": {
    "latency_analysis_file": "${LATENCY_ANALYSIS_FILE}",
    "error_analysis_file": "${ERROR_ANALYSIS_FILE}",
    "uptime_analysis_file": "${UPTIME_ANALYSIS_FILE}"
  },
  "sla": {
    "p95_latency_ms": ${latency_p95},
    "error_rate": ${error_rate},
    "uptime_rate": ${uptime_rate},
    "sla_score": ${sla_score}
  }
}
EOF
