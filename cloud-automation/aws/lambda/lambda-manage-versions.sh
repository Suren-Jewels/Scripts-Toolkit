#!/usr/bin/env bash
set -euo pipefail

# Lambda version management:
# - Publish new version
# - List versions

usage() {
  echo "Usage:"
  echo "  $0 publish <function_name>"
  echo "  $0 list <function_name>"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"
FUNCTION_NAME="$2"

case "${ACTION}" in
  publish)
    aws lambda publish-version \
      --function-name "${FUNCTION_NAME}" \
      --query "{Version:Version}" \
      --output table
    ;;
  list)
    aws lambda list-versions-by-function \
      --function-name "${FUNCTION_NAME}" \
      --query "Versions[].{Version:Version,LastModified:LastModified}" \
      --output table
    ;;
  *)
    usage
    ;;
esac
