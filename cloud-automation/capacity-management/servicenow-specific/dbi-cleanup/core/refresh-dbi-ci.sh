#!/usr/bin/env bash
set -euo pipefail

# Capability: Trigger a CI Refresh for a DBI CI in ServiceNow.

# Required variables
SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"     # e.g. https://dev12345.service-now.com
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"

DBI_SYSID="${1:?Usage: refresh-dbi-ci.sh <dbi_sys_id>}"

echo "Refreshing CI for DBI: ${DBI_SYSID}"

curl -s \
  -u "${SN_USER}:${SN_PASS}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{}' \
  "${SN_INSTANCE}/api/now/ui/ci/${DBI_SYSID}/refresh" \
  | jq .

echo "CI Refresh triggered for: ${DBI_SYSID}"
