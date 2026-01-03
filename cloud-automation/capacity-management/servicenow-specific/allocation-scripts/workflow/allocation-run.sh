#!/usr/bin/env bash
# Capability: Execute full allocation workflow.
# Creates timestamped run directory, executes all core scripts,
# and produces a unified allocation.json.

set -euo pipefail

: "${BASE_DIR:=runs}"
: "${DISCOVERED_CAPACITY:=capacity.json}"

TS=$(date +"%Y%m%d-%H%M%S")
RUN_DIR="$BASE_DIR/$TS"

mkdir -p "$RUN_DIR"

# Step 1: discover capacity
DISCOVER_OUT="$RUN_DIR/discovered.json"
DISCOVERED_CAPACITY="$DISCOVERED_CAPACITY" \
    allocation-scripts/core/discover-capacity.py > "$DISCOVER_OUT"

# Step 2: shared allocation
SHARED_OUT="$RUN_DIR/shared.json"
DISCOVERED_CAPACITY="$DISCOVER_OUT" \
    allocation-scripts/core/allocate-shared.py > "$SHARED_OUT"

# Step 3: private allocation
PRIVATE_OUT="$RUN_DIR/private.json"
DISCOVERED_CAPACITY="$DISCOVER_OUT" \
    allocation-scripts/core/allocate-private.py > "$PRIVATE_OUT"

# Step 4: domain extractors
DB_OUT="$RUN_DIR/db.json"
SHARED_ALLOC="$SHARED_OUT" PRIVATE_ALLOC="$PRIVATE_OUT" \
    allocation-scripts/core/allocate-domain-db.py > "$DB_OUT"

SCV_OUT="$RUN_DIR/scv.json"
SHARED_ALLOC="$SHARED_OUT" PRIVATE_ALLOC="$PRIVATE_OUT" \
    allocation-scripts/core/allocate-domain-scv.py > "$SCV_OUT"

APP_OUT="$RUN_DIR/app.json"
SHARED_ALLOC="$SHARED_OUT" PRIVATE_ALLOC="$PRIVATE_OUT" \
    allocation-scripts/core/allocate-domain-app.py > "$APP_OUT"

POD_OUT="$RUN_DIR/pod.json"
SHARED_ALLOC="$SHARED_OUT" PRIVATE_ALLOC="$PRIVATE_OUT" \
    allocation-scripts/core/allocate-domain-pod.py > "$POD_OUT"

PAIRPOD_OUT="$RUN_DIR/pairpod.json"
SHARED_ALLOC="$SHARED_OUT" PRIVATE_ALLOC="$PRIVATE_OUT" \
    allocation-scripts/core/allocate-domain-pairpod.py > "$PAIRPOD_OUT"

# Step 5: unify into allocation.json
cat <<EOF > "$RUN_DIR/allocation.json"
{
  "timestamp": "$TS",
  "discovered": $(cat "$DISCOVER_OUT"),
  "shared": $(cat "$SHARED_OUT"),
  "private": $(cat "$PRIVATE_OUT"),
  "domains": {
    "db": $(cat "$DB_OUT"),
    "scv": $(cat "$SCV_OUT"),
    "app": $(cat "$APP_OUT"),
    "pod": $(cat "$POD_OUT"),
    "pairpod": $(cat "$PAIRPOD_OUT")
  }
}
EOF

echo "$RUN_DIR/allocation.json"
