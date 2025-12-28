#!/usr/bin/env bash
set -euo pipefail

# Capability: Identify DBI nodes in 'Pending Retire' state.

# Required variables
SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"     # e.g. https://dev12345.service-now.com
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"

TABLE="cmdb_ci_db_instance"
QUERY="install_status=7"   # 7 = Pending Retire in CMDB

echo "Searching for DBI nodes in Pending Retire state..."

curl -s \
  -u "${SN_USER}:${SN_PASS}" \
  "${SN_INSTANCE}/api/now/table/${TABLE}?sysparm_query=${QUERY}&sysparm_fields=sys_id,name,install_status,sys_updated_on" \
  | jq .
