Scripts-Toolkit/capacity-management/incident-response/rhel8-migration/
    -> migration-orchestrator.sh
    ->
#!/usr/bin/env bash
# Capability: Full RHEL8 migration orchestration pipeline.
# Stages:
#   1. Pre‑migration assessment
#   2. Migration execution
#   3. Incident detection
#   4. Escalation
#   5. Rollback (if required)
#   6. History + metrics recording

set -euo pipefail

HOSTLIST="${HOSTLIST:-hosts.txt}"

echo "[1] Running pre‑migration assessment..."
./pre-migration-assessment/inventory-collector.sh "$HOSTLIST"
python3 pre-migration-assessment/compatibility-scanner.py "$HOSTLIST"
python3 pre-migration-assessment/readiness-score.py "$HOSTLIST"

echo "[2] Executing migration tooling..."
./migration-tooling/leapp-runner.sh "$HOSTLIST"
python3 migration-tooling/preupgrade-analyzer.py "$HOSTLIST"
./migration-tooling/migration-executor.sh "$HOSTLIST"

echo "[3] Detecting migration incidents..."
./migration-incident-detection/detect-boot-failure.sh "$HOSTLIST" || true
python3 migration-incident-detection/detect-service-regressions.py "$HOSTLIST" || true
./migration-incident-detection/detect-network-regressions.sh "$HOSTLIST" || true

echo "[4] Classifying severity..."
SEV=$(python3 migration-incident-detection/migration-severity-classifier.py "$HOSTLIST")
echo "Severity: $SEV"

echo "[5] Escalation..."
python3 migration-escalation/slack-migration-alert.py "$SEV" || true
./migration-escalation/pagerduty-migration-trigger.sh "$SEV" || true

echo "[6] Rollback if required..."
if [ "$SEV" = "BLOCKER" ]; then
    ./rollback-and-recovery/emergency-rollback.sh "$HOSTLIST"
fi

echo "[7] Recording migration history..."
python3 migration-history/record-migration-event.py "$SEV"

echo "[8] Updating metrics..."
python3 migration-metrics/migration-duration.py "$HOSTLIST"
python3 migration-metrics/success-rate-calculator.py

echo "RHEL8 migration orchestration completed."
exit 0
