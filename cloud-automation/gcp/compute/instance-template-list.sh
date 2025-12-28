#!/usr/bin/env bash
set -euo pipefail

# Capability: List Google Compute Engine instance templates.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud compute instance-templates list \
  --project="${PROJECT_ID}"
