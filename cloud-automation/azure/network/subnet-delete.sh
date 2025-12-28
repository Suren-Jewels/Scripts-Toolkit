#!/usr/bin/env bash
set -euo pipefail

# Capability: Delete a subnet within an Azure Virtual Network (VNet).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VNET_NAME="${VNET_NAME:?VNET_NAME is required}"
SUBNET_NAME="${SUBNET_NAME:?SUBNET_NAME is required}"

# Core logic
az network vnet subnet delete \
  --resource-group "${RESOURCE_GROUP}" \
  --vnet-name "${VNET_NAME}" \
  --name "${SUBNET_NAME}"
