#!/usr/bin/env bash
set -euo pipefail

# Capability: Display current compute resource usage and limits for an Azure region.

# Required variables
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
az vm list-usage \
  --location "${LOCATION}"
