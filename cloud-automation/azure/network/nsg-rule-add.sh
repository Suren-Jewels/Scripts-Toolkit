#!/usr/bin/env bash
set -euo pipefail

# Capability: Add a security rule to an Azure Network Security Group (NSG).

# Required variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
NSG_NAME="${NSG_NAME:?NSG_NAME is required}"
RULE_NAME="${RULE_NAME:?RULE_NAME is required}"
PRIORITY="${PRIORITY:?PRIORITY is required}"
DIRECTION="${DIRECTION:?DIRECTION is required}"
ACCESS="${ACCESS:?ACCESS is required}"
PROTOCOL="${PROTOCOL:?PROTOCOL is required}"
SOURCE="${SOURCE:?SOURCE is required}"
DESTINATION="${DESTINATION:?DESTINATION is required}"
PORT="${PORT:?PORT is required}"

# Core logic
az network nsg rule create \
  --resource-group "${RESOURCE_GROUP}" \
  --nsg-name "${NSG_NAME}" \
  --name "${RULE_NAME}" \
  --priority "${PRIORITY}" \
  --direction "${DIRECTION}" \
  --access "${ACCESS}" \
  --protocol "${PROTOCOL}" \
  --source-address-prefixes "${SOURCE}" \
  --destination-address-prefixes "${DESTINATION}" \
  --destination-port-ranges "${PORT}"
