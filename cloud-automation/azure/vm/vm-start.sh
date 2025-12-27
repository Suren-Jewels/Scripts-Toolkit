#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
LOCATION="${LOCATION:?LOCATION is required}"
VM_SIZE="${VM_SIZE:-Standard_DS1_v2}"
IMAGE="${IMAGE:-Ubuntu2204}"
ADMIN_USERNAME="${ADMIN_USERNAME:?ADMIN_USERNAME is required}"
AUTH_TYPE="${AUTH_TYPE:-ssh}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa.pub}"
VNET_NAME="${VNET_NAME:-${VM_NAME}-vnet}"
SUBNET_NAME="${SUBNET_NAME:-default}"
NSG_NAME="${NSG_NAME:-${VM_NAME}-nsg}"
PUBLIC_IP_NAME="${PUBLIC_IP_NAME:-${VM_NAME}-pip}"
NIC_NAME="${NIC_NAME:-${VM_NAME}-nic}"
OS_DISK_SIZE_GB="${OS_DISK_SIZE_GB:-64}"
TAGS="${TAGS:-}"

# Core logic
if ! az group show --name "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}" >/dev/null
fi

if ! az network vnet show --resource-group "${RESOURCE_GROUP}" --name "${VNET_NAME}" >/dev/null 2>&1; then
  az network vnet create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${VNET_NAME}" \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name "${SUBNET_NAME}" \
    --subnet-prefixes 10.0.0.0/24 \
    >/dev/null
else
  if ! az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "${SUBNET_NAME}" >/dev/null 2>&1; then
    az network vnet subnet create \
      --resource-group "${RESOURCE_GROUP}" \
      --vnet-name "${VNET_NAME}" \
      --name "${SUBNET_NAME}" \
      --address-prefixes 10.0.1.0/24 \
      >/dev/null
  fi
fi

if ! az network nsg show --resource-group "${RESOURCE_GROUP}" --name "${NSG_NAME}" >/dev/null 2>&1; then
  az network nsg create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${NSG_NAME}" \
    --location "${LOCATION}" \
    >/dev/null
fi

if ! az network public-ip show --resource-group "${RESOURCE_GROUP}" --name "${PUBLIC_IP_NAME}" >/dev/null 2>&1; then
  az network public-ip create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${PUBLIC_IP_NAME}" \
    --location "${LOCATION}" \
    --sku Standard \
    --allocation-method Static \
    >/dev/null
fi

if ! az network nic show --resource-group "${RESOURCE_GROUP}" --name "${NIC_NAME}" >/dev/null 2>&1; then
  az network nic create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${NIC_NAME}" \
    --location "${LOCATION}" \
    --vnet-name "${VNET_NAME}" \
    --subnet "${SUBNET_NAME}" \
    --network-security-group "${NSG_NAME}" \
    --public-ip-address "${PUBLIC_IP_NAME}" \
    >/dev/null
fi

TAGS_ARGS=()
if [ -n "${TAGS}" ]; then
  TAGS_ARGS+=(--tags "${TAGS}")
fi

AUTH_ARGS=()
if [ "${AUTH_TYPE}" = "ssh" ]; then
  if [ ! -f "${SSH_KEY_PATH}" ]; then
    echo "SSH key not found at ${SSH_KEY_PATH}" >&2
    exit 1
  fi
  AUTH_ARGS+=(--authentication-type ssh --ssh-key-values "@${SSH_KEY_PATH}")
elif [ "${AUTH_TYPE}" = "password" ]; then
  if [ -z "${ADMIN_PASSWORD}" ]; then
    echo "ADMIN_PASSWORD is required when AUTH_TYPE=password" >&2
    exit 1
  fi
  AUTH_ARGS+=(--authentication-type password --admin-password "${ADMIN_PASSWORD}")
else
  echo "Invalid AUTH_TYPE: ${AUTH_TYPE}. Use 'ssh' or 'password'." >&2
  exit 1
fi

az vm create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --location "${LOCATION}" \
  --size "${VM_SIZE}" \
  --image "${IMAGE}" \
  --admin-username "${ADMIN_USERNAME}" \
  --nics "${NIC_NAME}" \
  --os-disk-size-gb "${OS_DISK_SIZE_GB}" \
  "${AUTH_ARGS[@]}" \
  "${TAGS_ARGS[@]}"
