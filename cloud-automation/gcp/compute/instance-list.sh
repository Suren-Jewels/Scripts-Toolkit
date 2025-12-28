#!/usr/bin/env bash
set -euo pipefail

# Capability: List Google Compute Engine instances in a project/zone.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"

# Core logic
gcloud compute instances list \
  --project="${PROJECT_ID}" \
  --zones="${ZONE}"
