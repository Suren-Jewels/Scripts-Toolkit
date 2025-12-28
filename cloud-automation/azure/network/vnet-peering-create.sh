#!/usr/bin/env bash
set -euo pipefail

# Capability: Create VNet peering between two Azure Virtual Networks.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VNET_NAME="${VNET_NAME:?VNET_NAME is required}"
PEER_NAME="${PEER_NAME:?PEER_NAME is required}"
REMOTE_VNET_ID="${REMOTE_VNET_ID:?REMOTE_VNET_ID is required}"

# Core logic
az network vnet peering create \
  --resource-group "${RESOURCE_GROUP}" \
  --vnet-name "${VNET_NAME}" \
  --name "${PEER_NAME}" \
  --remote-vnet "${REMOTE_VNET_ID}" \
  --allow-vnet-access true
