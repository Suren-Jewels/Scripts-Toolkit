#!/usr/bin/env bash
# Capability: Send OpsGenie alert for migration issues.

set -euo pipefail

SEVERITY="${1:?Usage: opsgenie-migration-alert.sh <severity>}"
API_KEY="${OPSGENIE_API_KEY:?OPSGENIE_API_KEY not set}"

curl -X POST "https://api.opsgenie.com/v2/alerts" \
    -H "Content-Type: application/json" \
    -H "Authorization: GenieKey $API_KEY" \
    -d "{
        \"message\": \"RHEL8 Migration Alert\",
        \"description\": \"Severity: $SEVERITY\",
        \"priority\": \"P1\"
    }"

echo "OpsGenie alert sent."
