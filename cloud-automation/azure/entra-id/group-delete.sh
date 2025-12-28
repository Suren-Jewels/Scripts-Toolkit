#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Entra ID security group.

# Required variables
GROUP_ID="${GROUP_ID:?GROUP_ID is required}"

# Core logic
az ad group delete \
  --group "${GROUP_ID}"
