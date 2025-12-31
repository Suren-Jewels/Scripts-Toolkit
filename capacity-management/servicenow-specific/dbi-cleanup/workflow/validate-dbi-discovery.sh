#!/usr/bin/env bash
set -euo pipefail

# Capability: Validate DBI discovery timestamps to ensure they are not stale or missing.

# Required variables
SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"     # e.g. https://dev12345.service-now.com
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"
DAYS="${DAYS:-30}"                                        # Default threshold: 30 days

TABLE="cmdb_ci_db_instance"

# Query: missing discovery OR older than X days
QUERY="most_recent_discoveryISEMPTY^ORmost_recent_discoveryRELATIVELE@dayofweek@ago@${DAYS}"

echo "Validating DBI discovery timestamps older than ${DAYS} days..."

curl -s \
  -u "${SN_USER}:${SN_PASS}" \
  "${SN_INSTANCE}/api/now/table/${TABLE}?sysparm_query=${QUERY}&sysparm_fields=sys_id,name,most_recent_discovery,sys_updated_on" \
  | jq .
