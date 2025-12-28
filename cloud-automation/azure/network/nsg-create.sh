#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Network Security Group (NSG).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
NSG_NAME="${NSG_NAME:?NSG_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
az network nsg create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${NSG_NAME}" \
  --location "${LOCATION}"
