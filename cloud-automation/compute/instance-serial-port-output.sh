#!/usr/bin/env bash
set -euo pipefail

# Capability: Retrieve serial port output from a Google Compute Engine instance.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_NAME="${INSTANCE_NAME:?INSTANCE_NAME is required}"
PORT="${PORT:-1}"  # Default to port 1 if not provided

# Core logic
gcloud compute instances get-serial-port-output "${INSTANCE_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --port="${PORT}"
