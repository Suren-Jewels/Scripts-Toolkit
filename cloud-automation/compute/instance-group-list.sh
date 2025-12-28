#!/usr/bin/env bash
set -euo pipefail

# Capability: List Google Compute Engine instance groups.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud compute instance-groups list \
  --project="${PROJECT_ID}"
