#!/usr/bin/env bash
# Capability: Apply baseline configuration to a managed server.
# Executes a configurable baseline script or command.

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${NODE_NAME:?NODE_NAME is required}"

# External configuration command (e.g., ansible, ssh, ssm, custom script)
: "${CONFIG_CMD:?CONFIG_CMD is required}"

# Execute baseline configuration
$CONFIG_CMD "$NODE_NAME"

echo "Baseline configuration applied: $NODE_NAME"
