#!/usr/bin/env bash
set -euo pipefail

# Capability: List all available directory roles in Entra ID.

# Core logic
az role definition list
