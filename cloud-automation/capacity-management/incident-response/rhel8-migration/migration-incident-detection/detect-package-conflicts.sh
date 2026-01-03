migration-incident-detection/
    -> detect-package-conflicts.sh
    ->
#!/usr/bin/env bash
# Capability: Identify RPM dependency conflicts after migration.

set -euo pipefail

HOST="${1:?Usage: detect-package-conflicts.sh <host>}"

echo "=== Checking package conflicts on $HOST ==="

ssh "$HOST" "sudo dnf check --dependencies --all" \
    | grep -E 'conflict|problem|broken' \
    && echo "[CONFLICT DETECTED] $HOST" \
    || echo "[OK] $HOST"
