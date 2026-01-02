oncall-routing/
    -> pagerduty-trigger.sh
    ->
#!/usr/bin/env bash
# Capability: Trigger a PagerDuty incident for a given severity classification.
# Inputs:
#   EVENT_FILE      - JSON event payload
#   PD_ROUTING_KEY  - PagerDuty Events API v2 routing key
#   SEVERITY        - CRITICAL | MAJOR | MODERATE

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"
PD_ROUTING_KEY="${PD_ROUTING_KEY:?PD_ROUTING_KEY is required}"
SEVERITY="${SEVERITY:-NONE}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

payload=$(jq -c '.' "$EVENT_FILE")

curl -s -X POST "https://events.pagerduty.com/v2/enqueue" \
    -H "Content-Type: application/json" \
    -d "{
        \"routing_key\": \"${PD_ROUTING_KEY}\",
        \"event_action\": \"trigger\",
        \"payload\": {
            \"summary\": \"Automated incident: ${SEVERITY}\",
            \"severity\": \"${SEVERITY,,}\",
            \"source\": \"automation-engine\",
            \"custom_details\": ${payload}
        }
    }" | jq .

echo "PagerDuty trigger sent for severity: ${SEVERITY}"
