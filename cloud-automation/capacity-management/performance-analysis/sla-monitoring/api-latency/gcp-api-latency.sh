#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# gcp-api-latency.sh
# Location:
# Scripts-Toolkit/capacity-management/performance-analysis/sla-monitoring/api-latency/gcp-api-latency.sh
#
# Capability:
#   Measure HTTP latency for GCP-hosted API endpoints and emit
#   a JSON file with per-endpoint latency metrics.
# ------------------------------------------------------------

# --- Validation -------------------------------------------------------------

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required but not installed." >&2
  exit 1
fi

GCP_API_ENDPOINTS_FILE="${GCP_API_ENDPOINTS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-gcp-api-latency.json}"

if [[ -z "${GCP_API_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: GCP_API_ENDPOINTS_FILE environment variable is required." >&2
  exit 1
fi

if [[ ! -f "${GCP_API_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: Endpoints file not found: ${GCP_API_ENDPOINTS_FILE}" >&2
  exit 1
fi

# --- Helpers ---------------------------------------------------------------

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# --- Main ------------------------------------------------------------------

generated_at_utc="$(timestamp_utc)"

echo "{" > "${OUTPUT_FILE}"
echo "  \"meta\": {" >> "${OUTPUT_FILE}"
echo "    \"cloud\": \"gcp\"," >> "${OUTPUT_FILE}"
echo "    \"collector\": \"gcp-api-latency.sh\"," >> "${OUTPUT_FILE}"
echo "    \"generated_at_utc\": \"${generated_at_utc}\"" >> "${OUTPUT_FILE}"
echo "  }," >> "${OUTPUT_FILE}"
echo "  \"endpoints\": [" >> "${OUTPUT_FILE}"

first_record=true

tail -n +2 "${GCP_API_ENDPOINTS_FILE}" | while IFS=',' read -r service region endpoint; do
  service="$(echo "${service}" | xargs)"
  region="$(echo "${region}" | xargs)"
  endpoint="$(echo "${endpoint}" | xargs)"

  if [[ -z "${endpoint}" ]]; then
    continue
  fi

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

  ts="$(timestamp_utc)"

  if [[ "${first_record}" = true ]]; then
    first_record=false
  else
    echo "    ," >> "${OUTPUT_FILE}"
  fi

  cat <<EOF >> "${OUTPUT_FILE}"
    {
      "cloud": "gcp",
      "service": "${service}",
      "region": "${region}",
      "endpoint": "${endpoint}",
      "status_code": ${http_code},
      "latency_ms": ${latency_ms},
      "success": ${success},
      "timestamp_utc": "${ts}"
    }
EOF

done

echo "" >> "${OUTPUT_FILE}"
echo "  ]" >> "${OUTPUT_FILE}"
echo "}" >> "${OUTPUT_FILE}"
