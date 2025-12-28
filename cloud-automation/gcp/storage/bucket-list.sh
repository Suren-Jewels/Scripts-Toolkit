#!/usr/bin/env bash
set -euo pipefail

# Capability: List Google Cloud Storage buckets in a project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud storage buckets list \
  --project="${PROJECT_ID}" \
  --format=json
