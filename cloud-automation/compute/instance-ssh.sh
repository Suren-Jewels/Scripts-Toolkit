#!/usr/bin/env bash
set -euo pipefail

# Capability: SSH into a Google Compute Engine instance.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_NAME="${INSTANCE_NAME:?INSTANCE_NAME is required}"

# Core logic
gcloud compute ssh "${INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}"
