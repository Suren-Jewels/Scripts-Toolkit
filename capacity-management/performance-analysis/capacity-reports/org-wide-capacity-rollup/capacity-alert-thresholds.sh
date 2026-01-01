#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: Capacity Alert Threshold Validator
# Purpose   : Validate compute, storage, and network capacity values against
#             defined alert thresholds and emit a unified alert JSON payload.
# Output    : JSON (alerts + severity + affected resources)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found." >&2
  exit 1
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 <rollup.json> <thresholds.json>" >&2
  exit 1
fi

ROLLUP_FILE="$1"
THRESHOLDS_FILE="$2"

if [ ! -f "$ROLLUP_FILE" ]; then
  echo "ERROR: Rollup file not found: $ROLLUP_FILE" >&2
  exit 1
fi

if [ ! -f "$THRESHOLDS_FILE" ]; then
  echo "ERROR: Thresholds file not found: $THRESHOLDS_FILE" >&2
  exit 1
fi

# ----------------------------- MAIN LOGIC -------------------------------------
jq -n \
  --slurpfile rollup "$ROLLUP_FILE" \
  --slurpfile thresholds "$THRESHOLDS_FILE" \
  '
  def check(val; limit; name; id):
    if val != null and limit != null and (val > limit)
    then { resource: id, metric: name, value: val, threshold: limit, severity: "HIGH" }
    else empty
    end;

  {
    generated_at: now,
    alerts: (
      [
        # Compute capacity alerts
        check(
          $rollup[0].compute_capacity.used_cores;
          $thresholds[0].compute.used_cores;
          "used_cores";
          "compute"
        ),
        check(
          $rollup[0].compute_capacity.used_ram_gb;
          $thresholds[0].compute.used_ram_gb;
          "used_ram_gb";
          "compute"
        ),

        # Storage capacity alerts
        check(
          $rollup[0].storage_capacity.used_gb;
          $thresholds[0].storage.used_gb;
          "used_gb";
          "storage"
        ),

        # Network capacity alerts
        check(
          $rollup[0].network_capacity.used_bandwidth_gbps;
          $thresholds[0].network.used_bandwidth_gbps;
          "used_bandwidth_gbps";
          "network"
        )
      ]
      | map(select(. != null))
    ),
    alert_count: (.[].alerts | length)
  }
  '
