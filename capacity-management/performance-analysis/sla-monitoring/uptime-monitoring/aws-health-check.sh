#!/usr/bin/env bash
set -euo pipefail

# aws-health-check.sh

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required." >&2
  exit 1
fi

AWS_UPTIME_ENDPOINTS_FILE="${AWS_UPTIME_ENDPOINTS_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-aws-uptime.json}"

if [[ -z "${AWS_UPTIME_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: AWS_UPTIME_ENDPOINTS_FILE is required." >&2
  exit 1
fi

if [[ ! -f "${AWS_UPTIME_ENDPOINTS_FILE}" ]]; then
  echo "ERROR: Endpoints file not found: ${AWS_UPTIME_ENDPOINTS_FILE}" >&2
  exit 1
fi

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

generated_at_utc="$(timestamp_utc)"

echo "{" > "${OUTPUT_FILE}"
echo "  \"meta\": {" >> "${OUTPUT_FILE}"
echo "    \"cloud\": \"aws\"," >> "${OUTPUT_FILE}"
echo "    \"collector\": \"aws-health-check.sh\"," >> "${OUTPUT_FILE}"
echo "    \"generated_at_utc\": \"${generated_at_utc}\"" >> "${OUTPUT_FILE}"
echo "  }," >> "${OUTPUT_FILE}"
echo "  \"endpoints\": [" >> "${OUTPUT_FILE}"

first=true

tail -n +2 "${AWS_UPTIME_ENDPOINTS_FILE}" | while IFS=',' read -r service region endpoint; do
  service="$(echo "${service}" | xargs)"
  region="$(echo "${region}" | xargs)"
  endpoint="$(echo "${endpoint}" | xargs)"

  [[ -z "${endpoint}" ]] && continue

  http_code="$(curl -sS -o /dev/null -w "%{http_code}" "${endpoint}" || echo "")"

  success=false
  if [[ -n "${http_code}" ]] && [[ "${http_code}" -ge 200 && "${http_code}" -lt 400 ]]; then
    success=true
  else
    http_code=0
  fi

  ts="$(timestamp_utc)"

  if [[ "${first}" = true ]]; then
    first=false
  else
    echo "    ," >> "${OUTPUT_FILE}"
  fi

  cat <<EOF >> "${OUTPUT_FILE}"
    {
      "cloud": "aws",
      "service": "${service}",
      "region": "${region}",
      "endpoint": "${endpoint}",
      "status_code": ${http_code},
      "success": ${success},
      "timestamp_utc": "${ts}"
    }
EOF

done

echo "" >> "${OUTPUT_FILE}"
echo "  ]" >> "${OUTPUT_FILE}"
echo "}" >> "${OUTPUT_FILE}"
