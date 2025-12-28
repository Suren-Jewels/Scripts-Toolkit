#!/usr/bin/env bash
set -euo pipefail

# Capability: List IAM policy bindings for a Google Cloud project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"

# Core logic
gcloud projects get-iam-policy "${PROJECT_ID}" \
  --format=json
