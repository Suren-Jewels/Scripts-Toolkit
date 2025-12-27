#!/usr/bin/env bash
set -euo pipefail

# Lambda permission management:
# - Add permission
# - Remove permission

usage() {
  echo "Usage:"
  echo "  $0 add <function_name> <statement_id> <action> <principal> [source_arn]"
  echo "  $0 remove <function_name> <statement_id>"
  exit 1
}

if [[ $# -lt 3 ]]; then
  usage
fi

ACTION="$1"
FUNCTION_NAME="$2"
STATEMENT_ID="$3"

case "${ACTION}" in
  add)
    if [[ $# -lt 5 ]]; then usage; fi
    ACTION_NAME="$4"
    PRINCIPAL="$5"
    SOURCE_ARN="${6:-}"

    CMD="aws lambda add-permission \
      --function-name \"${FUNCTION_NAME}\" \
      --statement-id \"${STATEMENT_ID}\" \
      --action \"${ACTION_NAME}\" \
      --principal \"${PRINCIPAL}\""

    if [[ -n \"${SOURCE_ARN}\" ]]; then
      CMD+=" --source-arn \"${SOURCE_ARN}\""
    fi

    eval "${CMD}"
    echo "Permission added: ${STATEMENT_ID}"
    ;;
  remove)
    aws lambda remove-permission \
      --function-name "${FUNCTION_NAME}" \
      --statement-id "${STATEMENT_ID}"
    echo "Permission removed: ${STATEMENT_ID}"
    ;;
  *)
    usage
    ;;
esac
