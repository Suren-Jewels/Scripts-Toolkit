auto-remediation/
    -> restart-service.sh
    ->
#!/usr/bin/env bash
# Capability: Restart a failing service on a target host.
# Inputs:
#   SERVICE_NAME   - Name of the service to restart
#   TARGET_HOST    - Host where the service runs (optional)
#   EVENT_FILE     - JSON event payload (optional)

set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:?SERVICE_NAME is required}"
TARGET_HOST="${TARGET_HOST:-localhost}"
EVENT_FILE="${EVENT_FILE:-event.json}"

echo "Restarting service '${SERVICE_NAME}' on host '${TARGET_HOST}'..."

if [ -f "$EVENT_FILE" ]; then
    echo "Event context:"
    jq '.' "$EVENT_FILE"
fi

if [ "$TARGET_HOST" = "localhost" ]; then
    systemctl restart "$SERVICE_NAME"
else
    ssh "$TARGET_HOST" "sudo systemctl restart $SERVICE_NAME"
fi

echo "Service restart completed."
exit 0
