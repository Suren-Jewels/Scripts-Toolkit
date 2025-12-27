#!/usr/bin/env bash
set -euo pipefail

# Lambda function creation:
# - Create function
# - Set runtime, role, handler, zip file

usage() {
  echo "Usage: $0 <function_name> <runtime> <role_arn> <handler> <zip_file>"
  echo "  function_name : Lambda function name"
  echo "  runtime       : Lambda runtime (e.g., python3.9)"
  echo "  role_arn      : IAM role ARN"
  echo "  handler       : Function handler (e.g., index.handler)"
  echo "  zip_file      : Deployment package zip file"
  exit 1
}

if [[ $# -ne 5 ]]; then
  usage
fi

FUNCTION_NAME="$1"
RUNTIME="$2"
ROLE_ARN="$3"
HANDLER="$4"
ZIP_FILE="$5"

aws lambda create-function \
  --function-name "${FUNCTION_NAME}" \
  --runtime "${RUNTIME}" \
  --role "${ROLE_ARN}" \
  --handler "${HANDLER}" \
  --zip-file "fileb://${ZIP_FILE}"

echo "Lambda function created: ${FUNCTION_NAME}"
