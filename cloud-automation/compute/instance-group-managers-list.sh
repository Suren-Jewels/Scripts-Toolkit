#!/usr/bin/env bash
set -euo pipefail

# Capability: List managed instance groups (MIGs) in Google Compute Engine.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud compute instance-groups managed list \
  --project="${PROJECT_ID}"
