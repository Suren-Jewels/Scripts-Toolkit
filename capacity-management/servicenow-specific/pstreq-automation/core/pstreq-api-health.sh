#!/usr/bin/env bash
# Capability: Health check for ServiceNow PSTREQ API.
# Validates:
# - Instance reachability
# - Authentication
# - Table accessibility

set -euo pipefail

: "${SN_INSTANCE:?SN_INSTANCE is required}"
: "${SN_USER:?SN_USER is required}"
: "${SN_PASS:?SN_PASS is required}"

url="https://${SN_INSTANCE}.service-now.com/api/now/table/u_pstreq?sysparm_limit=1"

status=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "${SN_USER}:${SN_PASS}" \
  "$url")

if [[ "$status" != "200" ]]; then
  echo "ERROR: PSTREQ API health check failed (HTTP $status)"
  exit 1
fi

echo "PSTREQ API healthy (HTTP 200)"
