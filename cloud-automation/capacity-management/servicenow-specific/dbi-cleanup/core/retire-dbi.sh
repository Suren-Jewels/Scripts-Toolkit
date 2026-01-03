#!/usr/bin/env bash
set -euo pipefail

# Capability: Retire a single DBI CI safely via ServiceNow API.

# Required variables
SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"     # e.g. https://dev12345.service-now.com
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"

DBI_SYSID="${1:?Usage: retire-dbi.sh <dbi_sys_id>}"

TABLE="cmdb_ci_db_instance"

echo "Retiring DBI: ${DBI_SYSID}"

# Payload: set install_status to Retired (status code 7)
DATA='{"install_status":"7"}'

curl -s \
  -u "${SN_USER}:${SN_PASS}" \
  -X PATCH \
  -H "Content-Type: application/json" \
  -d "${DATA}" \
  "${SN_INSTANCE}/api/now/table/${TABLE}/${DBI_SYSID}" \
  | jq .

echo "DBI retirement request submitted for: ${DBI_SYSID}"
