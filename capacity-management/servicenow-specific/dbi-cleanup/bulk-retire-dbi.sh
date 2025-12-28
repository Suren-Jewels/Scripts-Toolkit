#!/usr/bin/env bash
set -euo pipefail

# Capability: Bulk retire DBI CIs safely via ServiceNow API.
# Usage: bulk-retire-dbi.sh dbi_list.txt

SN_INSTANCE="${SN_INSTANCE:?SN_INSTANCE is required}"
SN_USER="${SN_USER:?SN_USER is required}"
SN_PASS="${SN_PASS:?SN_PASS is required}"

INPUT_FILE="${1:?Usage: bulk-retire-dbi.sh <dbi_list_file>}"

TABLE="cmdb_ci_db_instance"
DATA='{"install_status":"7"}'   # 7 = Retired

echo "Starting bulk DBI retirement using list: ${INPUT_FILE}"
echo "---------------------------------------------"

while IFS= read -r DBI_SYSID; do
    [[ -z "$DBI_SYSID" ]] && continue

    echo "Retiring DBI: $DBI_SYSID"

    curl -s \
      -u "${SN_USER}:${SN_PASS}" \
      -X PATCH \
      -H "Content-Type: application/json" \
      -d "${DATA}" \
      "${SN_INSTANCE}/api/now/table/${TABLE}/${DBI_SYSID}" \
      | jq .

    echo "---------------------------------------------"
done < "$INPUT_FILE"

echo "Bulk DBI retirement completed."
