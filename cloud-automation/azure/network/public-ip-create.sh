#!/usr/bin/env bash
set -euo pipefail

# Capability: Create a Public IP address in Azure.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
PUBLIC_IP_NAME="${PUBLIC_IP_NAME:?PUBLIC_IP_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"
SKU="${SKU:?SKU is required}"
# Example: SKU="Standard"

# Core logic
az network public-ip create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${PUBLIC_IP_NAME}" \
  --location "${LOCATION}" \
  --sku "${SKU}"
