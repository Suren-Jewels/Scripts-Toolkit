#!/usr/bin/env bash
set -euo pipefail

# Capability: Set named ports for a Google Compute Engine instance group (unmanaged).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_NAME="${INSTANCE_GROUP_NAME:?INSTANCE_GROUP_NAME is required}"
NAMED_PORTS="${NAMED_PORTS:?NAMED_PORTS is required}" 
# Format example: "http:80,https:443"

# Core logic
gcloud compute instance-groups set-named-ports "${INSTANCE_GROUP_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --named-ports="${NAMED_PORTS}"
