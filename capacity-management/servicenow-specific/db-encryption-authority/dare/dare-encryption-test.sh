#!/usr/bin/env bash
# Capability: Validate DARE encryption and decryption for DB server.
# Performs:
# - Test payload encryption
# - Test payload decryption
# - Confirms round‑trip integrity

set -euo pipefail

: "${DARE_ENDPOINT:?DARE_ENDPOINT is required}"
: "${DARE_TOKEN:?DARE_TOKEN is required}"
: "${DBSERVER_ID:?DBSERVER_ID is required}"

PAYLOAD="DARE_ENCRYPTION_TEST_$(date +%s)"

echo "Testing DARE encryption for DB server: $DBSERVER_ID"

ENCRYPTED=$(curl -s -X POST "$DARE_ENDPOINT/encrypt" \
  -H "Authorization: Bearer $DARE_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"dbserver_id\":\"$DBSERVER_ID\",\"payload\":\"$PAYLOAD\"}" \
  | jq -r '.encrypted')

if [[ -z "$ENCRYPTED" ]]; then
  echo "ERROR: Encryption failed"
  exit 1
fi

DECRYPTED=$(curl -s -X POST "$DARE_ENDPOINT/decrypt" \
  -H "Authorization: Bearer $DARE_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"dbserver_id\":\"$DBSERVER_ID\",\"payload\":\"$ENCRYPTED\"}" \
  | jq -r '.decrypted')

if [[ "$DECRYPTED" != "$PAYLOAD" ]]; then
  echo "ERROR: Round‑trip encryption test failed"
  exit 1
fi

echo "DARE encryption test successful"
