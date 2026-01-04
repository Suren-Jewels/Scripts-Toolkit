#!/usr/bin/env bash
# FedRAMP Inventory Collector
# Collects system asset inventory for FedRAMP documentation.

set -euo pipefail

OUTPUT="inventory.json"

usage() {
    echo "Usage: $0 --output <file>"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="$2"; shift 2 ;;
        *) usage ;;
    esac
done

echo "[INFO] Collecting asset inventory..."

HOSTNAME=$(hostname)
OS=$(uname -s)
KERNEL=$(uname -r)
IP=$(hostname -I | awk '{print $1}')

cat <<EOF > "$OUTPUT"
{
  "assets": [
    "hostname:$HOSTNAME",
    "os:$OS",
    "kernel:$KERNEL",
    "ip:$IP"
  ]
}
EOF

echo "[RESULT] Inventory collected → $OUTPUT"
