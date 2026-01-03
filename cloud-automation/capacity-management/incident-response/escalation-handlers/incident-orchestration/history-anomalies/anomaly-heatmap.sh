incident-orchestration/history-anomalies/
    -> anomaly-heatmap.sh
    ->
#!/usr/bin/env bash
# Capability: Generate ASCII heatmap of anomaly scores.
# Requires: anomaly-score.py output piped in.

set -euo pipefail

INPUT=$(cat)

echo "Anomaly Heatmap:"
echo "$INPUT" | jq -r '.[] | "\(.file): " + ("#" * .score)'
