#!/usr/bin/env bash
set -euo pipefail

# Lambda code update:
# - Update function code with new zip file

usage() {
  echo "Usage: $0 <function_name> <zip_file>"
  echo "  function_name : Lambda function name"
  echo "  zip_file      : Deployment package zip file"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

FUNCTION_NAME="$1"
ZIP_FILE="$2"

aws lambda update-function-code \
  --function-name "${FUNCTION_NAME}" \
  --zip-file "fileb://${ZIP_FILE}"

echo "Lambda function code updated: ${FUNCTION_NAME}"
