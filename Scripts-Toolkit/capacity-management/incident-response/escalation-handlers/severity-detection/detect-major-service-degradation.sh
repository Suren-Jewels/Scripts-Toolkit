severity-detection/
    -> detect-sev2.sh
    ->
#!/usr/bin/env bash
# Capability: Detect SEV2 incidents based on major degradation.
# Criteria:
# - Error rate >= 10%
# - Latency >= 1200ms
# - Uptime < 97%
# - Explicit SEV2 flag in event payload

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

error_rate=$(jq -r '.error_rate' "$EVENT_FILE")
latency=$(jq -r '.latency_ms' "$EVENT_FILE")
uptime=$(jq -r '.uptime' "$EVENT_FILE")
sev_flag=$(jq -r '.sev2_flag' "$EVENT_FILE")

if [ "$sev_flag" = "true" ]; then
    echo "SEV2"
    exit 0
fi

if (( $(echo "$error_rate >= 10" | bc -l) )) \
   || (( $(echo "$latency >= 1200" | bc -l) )) \
   || (( $(echo "$uptime < 97" | bc -l) )); then
    echo "SEV2"
    exit 0
fi

echo "NO-SEV2"
exit 0
