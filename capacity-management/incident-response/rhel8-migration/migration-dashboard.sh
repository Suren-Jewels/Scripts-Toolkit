Scripts-Toolkit/capacity-management/incident-response/rhel8-migration/
    -> migration-dashboard.sh
    ->
#!/usr/bin/env bash
# Capability: CLI dashboard for migration status.

set -euo pipefail

echo "=== RHEL8 Migration Dashboard ==="
echo "Recent Migration Events:"
python3 migration-history/get-latest-migration.py

echo ""
echo "Migration Health Summary:"
python3 migration-health-summary.py

echo ""
echo "Anomaly Overview:"
python3 migration-anomalies/summarize-anomalies.py || true
