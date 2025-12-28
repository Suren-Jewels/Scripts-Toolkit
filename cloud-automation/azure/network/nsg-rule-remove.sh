#!/usr/bin/env bash
set -euo pipefail

# Capability: Remove a security rule from an Azure Network Security Group (NSG).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
NSG_NAME="${NSG_NAME:?NSG_NAME is required}"
RULE_NAME="${RULE_NAME:?RULE_NAME is required}"

# Core logic
az network nsg rule delete \
  --resource-group "${RESOURCE_GROUP}" \
  --nsg-name "${NSG_NAME}" \
  --name "${RULE_NAME}"
