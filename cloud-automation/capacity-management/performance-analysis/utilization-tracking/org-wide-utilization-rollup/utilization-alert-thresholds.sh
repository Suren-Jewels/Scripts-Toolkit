#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: Utilization Alert Threshold Validator
# Purpose   : Validate compute, storage, and network utilization values against
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
        # Compute alerts
        ($rollup[0].compute.instance_reports[]? // []) as $inst |
        check($inst.cpu_avg; $thresholds[0].compute.cpu; "cpu_avg"; $inst.instance),
        check($inst.ram_avg; $thresholds[0].compute.ram; "ram_avg"; $inst.instance),

        # Storage alerts
        ($rollup[0].storage.filestore_reports[]? // []) as $st |
        check($st.throughput_read_avg; $thresholds[0].storage.read; "throughput_read_avg"; $st.name),
        check($st.throughput_write_avg; $thresholds[0].storage.write; "throughput_write_avg"; $st.name),

        # Network alerts
        ($rollup[0].network.vpc_reports[]? // []) as $vpc |
        check($vpc.throughput_in_sum; $thresholds[0].network.in; "throughput_in_sum"; $vpc.vpc),
        check($vpc.throughput_out_sum; $thresholds[0].network.out; "throughput_out_sum"; $vpc.vpc),
        check($vpc.packet_drops_sum; $thresholds[0].network.drops; "packet_drops_sum"; $vpc.vpc)
      ]
      | map(select(. != null))
    ),
    alert_count: (.[].alerts | length)
  }
  '
