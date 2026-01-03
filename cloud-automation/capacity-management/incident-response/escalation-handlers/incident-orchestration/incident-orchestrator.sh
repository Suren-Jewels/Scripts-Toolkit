incident-orchestration/
    -> incident-orchestrator.sh
    ->
#!/usr/bin/env bash
# Capability: Full incident orchestration pipeline.
# Stages:
#   1. Classify severity
#   2. Route on-call
#   3. Execute remediation
#   4. Broadcast updates
#   5. Record history

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"

echo "[1] Classifying severity..."
SEVERITY=$(python3 escalation-handlers/severity-detection/severity-classifier.py)
echo "Severity detected: $SEVERITY"

echo "[2] Routing on-call..."
export SEVERITY
export EVENT_FILE
python3 escalation-handlers/oncall-routing/slack-escalation.py || true
chmod +x escalation-handlers/oncall-routing/pagerduty-trigger.sh
./escalation-handlers/oncall-routing/pagerduty-trigger.sh || true

echo "[3] Running remediation engine..."
python3 escalation-handlers/auto-remediation/remediation-engine.py || true

echo "[4] Broadcasting updates..."
python3 escalation-handlers/incident-orchestration/comms/slack-incident-broadcast.py || true
python3 escalation-handlers/incident-orchestration/comms/teams-incident-broadcast.py || true

echo "[5] Recording incident history..."
python3 escalation-handlers/incident-orchestration/history/record-incident-history.py

echo "Incident orchestration completed."
exit 0
