#!/usr/bin/env bash
set -euo pipefail

# Input variables
RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
VM_NAME="${VM_NAME:?VM_NAME is required}"
DELETE_DISKS="${DELETE_DISKS:-true}"
DELETE_NICS="${DELETE_NICS:-true}"
DELETE_PUBLIC_IP="${DELETE_PUBLIC_IP:-true}"

# Core logic
az vm delete \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --yes

if [ "${DELETE_DISKS}" = "true" ]; then
  DISK_ID=$(az disk list --resource-group "${RESOURCE_GROUP}" --query "[?contains(name, '${VM_NAME}')].id" -o tsv)
  if [ -n "${DISK_ID}" ]; then
    az disk delete --ids ${DISK_ID} --yes
  fi
fi

if [ "${DELETE_NICS}" = "true" ]; then
  NIC_ID=$(az network nic list --resource-group "${RESOURCE_GROUP}" --query "[?contains(name, '${VM_NAME}')].id" -o tsv)
  if [ -n "${NIC_ID}" ]; then
    az network nic delete --ids ${NIC_ID}
  fi
fi

if [ "${DELETE_PUBLIC_IP}" = "true" ]; then
  PIP_ID=$(az network public-ip list --resource-group "${RESOURCE_GROUP}" --query "[?contains(name, '${VM_NAME}')].id" -o tsv)
  if [ -n "${PIP_ID}" ]; then
    az network public-ip delete --ids ${PIP_ID}
  fi
fi
