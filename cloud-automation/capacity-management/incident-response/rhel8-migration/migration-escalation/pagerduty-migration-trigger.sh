#!/usr/bin/env bash
# Capability: Trigger PagerDuty incident for migration blockers.

set -euo pipefail

SEVERITY="${1:?Usage: pagerduty-migration-trigger.sh <severity>}"

if [ "$SEVERITY" != "BLOCKER" ]; then
    echo "PagerDuty trigger skipped (severity: $SEVERITY)"
    exit 0
fi

PD_ROUTING_KEY="${PD_ROUTING_KEY:?PD_ROUTING_KEY not set}"

curl -X POST "https://events.pagerduty.com/v2/enqueue" \
    -H "Content-Type: application/json" \
    -d "{
        \"routing_key\": \"$PD_ROUTING_KEY\",
        \"event_action\": \"trigger\",
        \"payload\": {
            \"summary\": \"RHEL8 Migration BLOCKER detected\",
            \"severity\": \"critical\",
            \"source\": \"migration-system\"
        }
    }"

echo "PagerDuty BLOCKER triggered."
