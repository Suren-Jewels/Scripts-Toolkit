#!/usr/bin/env bash
set -euo pipefail

# Lambda alias management:
# - Create alias
# - Update alias
# - Delete alias
# - List aliases

usage() {
  echo "Usage:"
  echo "  $0 create <function_name> <alias_name> <version>"
  echo "  $0 update <function_name> <alias_name> <version>"
  echo "  $0 delete <function_name> <alias_name>"
  echo "  $0 list <function_name>"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"
FUNCTION_NAME="$2"

case "${ACTION}" in
  create)
    if [[ $# -ne 4 ]]; then usage; fi
    ALIAS_NAME="$3"
    VERSION="$4"
    aws lambda create-alias \
      --function-name "${FUNCTION_NAME}" \
      --name "${ALIAS_NAME}" \
      --function-version "${VERSION}"
    echo "Alias created: ${ALIAS_NAME}"
    ;;
  update)
    if [[ $# -ne 4 ]]; then usage; fi
    ALIAS_NAME="$3"
    VERSION="$4"
    aws lambda update-alias \
      --function-name "${FUNCTION_NAME}" \
      --name "${ALIAS_NAME}" \
      --function-version "${VERSION}"
    echo "Alias updated: ${ALIAS_NAME}"
    ;;
  delete)
    if [[ $# -ne 3 ]]; then usage; fi
    ALIAS_NAME="$3"
    aws lambda delete-alias \
      --function-name "${FUNCTION_NAME}" \
      --name "${ALIAS_NAME}"
    echo "Alias deleted: ${ALIAS_NAME}"
    ;;
  list)
    aws lambda list-aliases \
      --function-name "${FUNCTION_NAME}" \
      --query "Aliases[].{Name:Name,Version:FunctionVersion}" \
      --output table
    ;;
  *)
    usage
    ;;
esac
