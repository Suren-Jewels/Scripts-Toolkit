#!/usr/bin/env bash
set -euo pipefail

# Capability: List instances within a Google Compute Engine instance group (unmanaged).

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ZONE="${ZONE:?ZONE is required}"
INSTANCE_GROUP_NAME="${INSTANCE_GROUP_NAME:?INSTANCE_GROUP_NAME is required}"

# Core logic
gcloud compute instance-groups list-instances "${INSTANCE_GROUP_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}"
