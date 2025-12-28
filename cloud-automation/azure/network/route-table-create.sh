#!/usr/bin/env bash
set -euo pipefail

# Capability: Create an Azure Route Table.

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
ROUTE_TABLE_NAME="${ROUTE_TABLE_NAME:?ROUTE_TABLE_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"

# Core logic
az network route-table create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ROUTE_TABLE_NAME}" \
  --location "${LOCATION}"
