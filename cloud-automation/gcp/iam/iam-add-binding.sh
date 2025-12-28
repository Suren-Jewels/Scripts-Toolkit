#!/usr/bin/env bash
set -euo pipefail

# Capability: Add an IAM policy binding to a Google Cloud project.

# Required variables
PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
ROLE="${ROLE:?ROLE is required}"
MEMBER="${MEMBER:?MEMBER is required}"

# Core logic
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --role="${ROLE}" \
  --member="${MEMBER}"
