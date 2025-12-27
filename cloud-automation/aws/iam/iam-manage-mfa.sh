#!/usr/bin/env bash
set -euo pipefail

# IAM MFA management:
# - Enable MFA
# - Deactivate MFA
# - List MFA devices

usage() {
  echo "Usage:"
  echo "  $0 enable <username> <serial_number> <code1> <code2>"
  echo "  $0 disable <username> <serial_number>"
  echo "  $0 list <username>"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"
USERNAME="$2"

case "${ACTION}" in
  enable)
    if [[ $# -ne 5 ]]; then usage; fi
    SERIAL="$3"
    CODE1="$4"
    CODE2="$5"
    aws iam enable-mfa-device \
      --user-name "${USERNAME}" \
      --serial-number "${SERIAL}" \
      --authentication-code1 "${CODE1}" \
      --authentication-code2 "${CODE2}"
    echo "MFA enabled for user: ${USERNAME}"
    ;;
  disable)
    if [[ $# -ne 3 ]]; then usage; fi
    SERIAL="$3"
    aws iam deactivate-mfa-device \
      --user-name "${USERNAME}" \
      --serial-number "${SERIAL}"
    echo "MFA disabled for user: ${USERNAME}"
    ;;
  list)
    aws iam list-mfa-devices \
      --user-name "${USERNAME}" \
      --query "MFADevices[].{SerialNumber:SerialNumber,EnableDate:EnableDate}" \
      --output table
    ;;
  *)
    usage
    ;;
esac
