severity-detection/
    -> detect-sev3.sh
    ->
#!/usr/bin/env bash
# Capability: Detect SEV3 incidents based on moderate degradation.
# Criteria:
# - Error rate >= 5%
# - Latency >= 800ms
# - Uptime < 99%
# - Explicit SEV3 flag in event payload

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

error_rate=$(jq -r '.error_rate' "$EVENT_FILE")
latency=$(jq -r '.latency_ms' "$EVENT_FILE")
uptime=$(jq -r '.uptime' "$EVENT_FILE")
sev_flag=$(jq -r '.sev3_flag' "$EVENT_FILE")

if [ "$sev_flag" = "true" ]; then
    echo "SEV3"
    exit 0
fi

if (( $(echo "$error_rate >= 5" | bc -l) )) \
   || (( $(echo "$latency >= 800" | bc -l) )) \
   || (( $(echo "$uptime < 99" | bc -l) )); then
    echo "SEV3"
    exit 0
fi

echo "NO-SEV3"
exit 0
