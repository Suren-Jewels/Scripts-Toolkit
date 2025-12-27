#!/usr/bin/env bash
set -euo pipefail

# Lambda inventory reporting:
# - List all functions
# - List configuration for a specific function (optional)

usage() {
  echo "Usage: $0 [function_name]"
  echo "  function_name : Optional Lambda function to show details"
  exit 1
}

FUNCTION_NAME="${1:-}"

aws lambda list-functions \
  --query "Functions[].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified}" \
  --output table

if [[ -n "${FUNCTION_NAME}" ]]; then
  aws lambda get-function-configuration \
    --function-name "${FUNCTION_NAME}" \
    --output table
fi
