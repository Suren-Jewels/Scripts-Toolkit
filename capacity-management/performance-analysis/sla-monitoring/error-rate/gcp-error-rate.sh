#!/usr/bin/env bash
set -euo pipefail

# gcp-error-rate.sh

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required." >&2
  exit 1
fi

GCP_ERROR_ENDPOINTS_FILE="${GCP_ERROR_ENDPOINTS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-gcp-error-rate.json}"

if [[ -z "${GCP_ERROR_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: GCP_ERROR_ENDPOINTS_FILE is required." >&2
  exit 1
fi

if [[ ! -f "${GCP_ERROR_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: Endpoints file not found: ${GCP_ERROR_ENDPOINTS_FILE}" >&2
  exit 1
fi

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

generated_at_utc="$(timestamp_utc)"

echo "{" > "${OUTPUT_FILE}"
echo "  \"meta\": {" >> "${OUTPUT_FILE}"
echo "    \"cloud\": \"gcp\"," >> "${OUTPUT_FILE}"
echo "    \"collector\": \"gcp-error-rate.sh\"," >> "${OUTPUT_FILE}"
echo "    \"generated_at_utc\": \"${generated_at_utc}\"" >> "${OUTPUT_FILE}"
echo "  }," >> "${OUTPUT_FILE}"
echo "  \"endpoints\": [" >> "${OUTPUT_FILE}"

first=true

tail -n +2 "${GCP_ERROR_ENDPOINTS_FILE}" | while IFS=',' read -r service region endpoint; do
  service="$(echo "${service}" | xargs)"
  region="$(echo "${region}" | xargs)"
  endpoint="$(echo "${endpoint}" | xargs)"

  [[ -z "${endpoint}" ]] && continue

  http_code="$(curl -sS -o /dev/null -w "%{http_code}" "${endpoint}" || echo "")"

  error=false
  if [[ -z "${http_code}" ]] || [[ "${http_code}" -ge 400 ]]; then
    error=true
    http_code="${http_code:-0}"
  fi

  ts="$(timestamp_utc)"

  if [[ "${first}" = true ]]; then
    first=false
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
      "error": ${error},
      "timestamp_utc": "${ts}"
    }
EOF

done

echo "" >> "${OUTPUT_FILE}"
echo "  ]" >> "${OUTPUT_FILE}"
echo "}" >> "${OUTPUT_FILE}"
