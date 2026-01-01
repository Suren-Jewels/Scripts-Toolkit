#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Capability: GCP Compute Capacity Summary
# Purpose   : Summarize vCPU, RAM, and instance distribution across all projects.
# Output    : JSON (per-project + global rollup)
# Author    : Suren Jewels (FixWare) — Where broken becomes better.
# ------------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- VALIDATION -------------------------------------
if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI not found." >&2
  exit 1
fi

# ----------------------------- VARIABLES --------------------------------------
PROJECTS=$(gcloud projects list --format="value(projectId)")

# ----------------------------- FUNCTIONS --------------------------------------
collect_project_data() {
  local project="$1"

  gcloud compute instances list \
    --project "$project" \
    --format="json(name,machineType,status,zone)" | jq -r --arg project "$project" '
    {
      project: $project,
      instances: (.[] | {
        name: .name,
        zone: .zone,
        machineType: (.machineType | split("/")[-1])
      }) // []
    }
  '
}

# ----------------------------- MAIN LOGIC -------------------------------------
RESULTS=()

for p in $PROJECTS; do
  DATA=$(collect_project_data "$p")
  RESULTS+=("$DATA")
done

printf '%s\n' "${RESULTS[@]}" | jq -s '
  {
    generated_at: now,
    project_reports: .,
    project_count: (. | length)
  }
'
