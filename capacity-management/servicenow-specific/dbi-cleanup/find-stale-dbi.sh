#!/usr/bin/env bash
set -euo pipefail

# Capability: Identify stale DBI nodes in CMDB based on discovery timestamp.

# Required variables
SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"          # e.g. https://dev12345.service-now.com
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"
DAYS="${DAYS:-30}"                                             # Default: 30 days

# CMDB table for DBI nodes
TABLE="cmdb_ci_db_instance"

# Build query: discovery older than X days OR missing
QUERY="sys_updated_onRELATIVELE@dayofweek@ago@${DAYS}^ORmost_recent_discoveryISEMPTY"

echo "Searching for stale DBI nodes older than ${DAYS} days..."

curl -s \
  -u "${SN_USER}:${SN_PASS}" \
  "${SN_INSTANCE}/api/now/table/${TABLE}?sysparm_query=${QUERY}&sysparm_fields=sys_id,name,most_recent_discovery,sys_updated_on" \
  | jq .
