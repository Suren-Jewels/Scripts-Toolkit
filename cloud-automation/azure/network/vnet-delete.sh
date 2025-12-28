#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete an Azure Virtual Network (VNet).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VNET_NAME="${VNET_NAME:?VNET_NAME is required}"

# Core logic
az network vnet delete \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VNET_NAME}"
