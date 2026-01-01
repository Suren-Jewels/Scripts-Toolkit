#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: Multi‑Cloud Utilization Rollup
# Purpose   : Merge compute, storage, and network utilization reports from GCP,
#             Azure, and AWS into a unified cross‑cloud JSON rollup.
# Output    : JSON (org‑wide utilization snapshot)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found." >&2
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <input_directory>" >&2
  exit 1
fi

INPUT_DIR="$1"

if [ ! -d "$INPUT_DIR" ]; then
  echo "ERROR: Input directory does not exist: $INPUT_DIR" >&2
  exit 1
fi

# ----------------------------- FUNCTIONS --------------------------------------
collect_reports() {
  local dir="$1"
  local files=("$dir"/*.json)

  for f in "${files[@]}"; do
    if [ -f "$f" ]; then
      cat "$f"
    fi
  done
}

# ----------------------------- MAIN LOGIC -------------------------------------
RAW=$(collect_reports "$INPUT_DIR")

ROLLUP=$(printf '%s\n' "$RAW" | jq -s '
{
  generated_at: now,
  compute: (map(select(.instance_reports)) | add // {}),
  storage: (map(select(.filestore_reports or .storage_reports)) | add // {}),
  network: (map(select(.vpc_reports or .network_reports)) | add // {}),
  load_balancers: (map(select(.lb_utilization)) | add // {})
}
')

echo "$ROLLUP"
