#!/usr/bin/env bash
set -euo pipefail

# Capability: List all available VM sizes in a given Azure region.

# Required variables
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
az vm list-sizes \
  --location "${LOCATION}"
