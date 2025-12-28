#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a subnet within an Azure Virtual Network (VNet).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VNET_NAME="${VNET_NAME:?VNET_NAME is required}"
SUBNET_NAME="${SUBNET_NAME:?SUBNET_NAME is required}"
ADDRESS_PREFIX="${ADDRESS_PREFIX:?ADDRESS_PREFIX is required}"
# Example: ADDRESS_PREFIX="10.0.1.0/24"

# Core logic
az network vnet subnet create \
  --resource-group "${RESOURCE_GROUP}" \
  --vnet-name "${VNET_NAME}" \
  --name "${SUBNET_NAME}" \
  --address-prefixes "${ADDRESS_PREFIX}"
