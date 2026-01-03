#!/usr/bin/env bash
set -euo pipefail

# aws-api-latency.sh

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required." >&2
  exit 1
fi

AWS_API_ENDPOINTS_FILE="${AWS_API_ENDPOINTS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-aws-api-latency.json}"

if [[ -z "${AWS_API_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: AWS_API_ENDPOINTS_FILE is required." >&2
  exit 1
fi

if [[ ! -f "${AWS_API_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: Endpoints file not found: ${AWS_API_ENDPOINTS_FILE}" >&2
  exit 1
fi

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

generated_at_utc="$(timestamp_utc)"

echo "{" > "${OUTPUT_FILE}"
echo "  \"meta\": {" >> "${OUTPUT_FILE}"
echo "    \"cloud\": \"aws\"," >> "${OUTPUT_FILE}"
echo "    \"collector\": \"aws-api-latency.sh\"," >> "${OUTPUT_FILE}"
echo "    \"generated_at_utc\": \"${generated_at_utc}\"" >> "${OUTPUT_FILE}"
echo "  }," >> "${OUTPUT_FILE}"
echo "  \"endpoints\": [" >> "${OUTPUT_FILE}"

first=true

tail -n +2 "${AWS_API_ENDPOINTS_FILE}" | while IFS=',' read -r service region endpoint; do
  service="$(echo "${service}" | xargs)"
  region="$(echo "${region}" | xargs)"
  endpoint="$(echo "${endpoint}" | xargs)"

  [[ -z "${endpoint}" ]] && continue

  start_ns="$(date +%s%N)"
  http_code="$(curl -sS -o /dev/null -w "%{http_code}" "${endpoint}" || echo "")"
  end_ns="$(date +%s%N)"

  latency_ms="null"
  success=false

  if [[ -n "${http_code}" ]]; then
    elapsed_ns=$((end_ns - start_ns))
    latency_ms=$((elapsed_ns / 1000000))
    if [[ "${http_code}" -ge 200 && "${http_code}" -lt 400 ]]; then
      success=true
    fi
  else
    http_code=0
  fi

  ts="$(timestamp
