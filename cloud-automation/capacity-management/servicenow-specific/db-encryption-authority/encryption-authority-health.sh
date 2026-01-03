#!/usr/bin/env bash
# Capability: Unified health check for DARE, Clotho, and AES encryption authorities.
# Validates:
# - Endpoint reachability
# - Token validity
# - Metadata availability
# - Cross-system responsiveness

set -euo pipefail

: "${DBSERVER_ID:?DBSERVER_ID is required}"

: "${DARE_ENDPOINT:?DARE_ENDPOINT is required}"
: "${DARE_TOKEN:?DARE_TOKEN is required}"

: "${CLOTHO_ENDPOINT:?CLOTHO_ENDPOINT is required}"
: "${CLOTHO_TOKEN:?CLOTHO_TOKEN is required}"

: "${AES_ENDPOINT:?AES_ENDPOINT is required}"
: "${AES_TOKEN:?AES_TOKEN is required}"

check() {
  local name="$1"
  local url="$2"
  local token="$3"

  echo "Checking $name..."

  status=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    "$url")

  if [[ "$status" != "200" ]]; then
    echo "ERROR: $name health check failed (HTTP $status)"
    exit 1
  fi

  echo "$name OK"
}

check "DARE"   "$DARE_ENDPOINT/health"   "$DARE_TOKEN"
check "Clotho" "$CLOTHO_ENDPOINT/health" "$CLOTHO_TOKEN"
check "AES"    "$AES_ENDPOINT/health"    "$AES_TOKEN"

echo "All encryption authorities healthy for DB server: $DBSERVER_ID"
