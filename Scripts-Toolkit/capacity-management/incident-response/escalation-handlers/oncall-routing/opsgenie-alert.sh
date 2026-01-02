oncall-routing/
    -> opsgenie-alert.sh
    ->
#!/usr/bin/env bash
# Capability: Send an OpsGenie alert for a given severity classification.
# Inputs:
#   EVENT_FILE       - JSON event payload
#   OPSGENIE_API_KEY - OpsGenie API key
#   SEVERITY         - CRITICAL | MAJOR | MODERATE

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"
OPSGENIE_API_KEY="${OPSGENIE_API_KEY:?OPSGENIE_API_KEY is required}"
SEVERITY="${SEVERITY:-NONE}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

payload=$(jq -c '.' "$EVENT_FILE")

curl -s -X POST "https://api.opsgenie.com/v2/alerts" \
    -H "Content-Type: application/json" \
    -H "Authorization: GenieKey ${OPSGENIE_API_KEY}" \
    -d "{
        \"message\": \"Automated incident: ${SEVERITY}\",
        \"priority\": \"${SEVERITY}\",
        \"details\": ${payload}
    }" | jq .

echo "OpsGenie alert sent for severity: ${SEVERITY}"
