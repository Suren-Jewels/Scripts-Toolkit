#!/usr/bin/env bash
set -euo pipefail

# Lambda invocation:
# - Invoke function with optional payload

usage() {
  echo "Usage: $0 <function_name> [payload_json_file]"
  echo "  function_name      : Lambda function name"
  echo "  payload_json_file  : Optional JSON payload file"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

FUNCTION_NAME="$1"
PAYLOAD_FILE="${2:-}"

if [[ -n "${PAYLOAD_FILE}" ]]; then
  aws lambda invoke \
    --function-name "${FUNCTION_NAME}" \
    --payload "file://${PAYLOAD_FILE}" \
    response.json >/dev/null
else
  aws lambda invoke \
    --function-name "${FUNCTION_NAME}" \
    response.json >/dev/null
fi

echo "Lambda invoked: ${FUNCTION_NAME}"
echo "Response saved to: response.json"
