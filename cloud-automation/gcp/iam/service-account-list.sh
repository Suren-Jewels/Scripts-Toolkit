#!/usr/bin/env bash
set -euo pipefail

# Capability: List Google Cloud service accounts in a project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud iam service-accounts list \
  --project="${PROJECT_ID}"
