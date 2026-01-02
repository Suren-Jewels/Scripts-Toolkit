severity-detection/
    -> detect-sev1.sh
    -> 
#!/usr/bin/env bash
# Capability: Detect SEV1 incidents based on critical signals.
# Criteria:
# - Error rate >= 20%
# - Latency >= 2000ms
# - Uptime < 95%
# - Explicit SEV1 flag in event payload

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

error_rate=$(jq -r '.error_rate' "$EVENT_FILE")
latency=$(jq -r '.latency_ms' "$EVENT_FILE")
uptime=$(jq -r '.uptime' "$EVENT_FILE")
sev_flag=$(jq -r '.sev1_flag' "$EVENT_FILE")

if [ "$sev_flag" = "true" ]; then
    echo "SEV1"
    exit 0
fi

if (( $(echo "$error_rate >= 20" | bc -l) )) \
   || (( $(echo "$latency >= 2000" | bc -l) )) \
   || (( $(echo "$uptime < 95" | bc -l) )); then
    echo "SEV1"
    exit 0
fi

echo "NO-SEV1"
exit 0
