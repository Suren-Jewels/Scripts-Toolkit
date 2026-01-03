#!/usr/bin/env bash
# Capability: Validate AES encryption and decryption for DB server.
# Performs:
# - Test payload encryption
# - Test payload decryption
# - Confirms round‑trip integrity

set -euo pipefail

: "${AES_ENDPOINT:?AES_ENDPOINT is required}"
: "${AES_TOKEN:?AES_TOKEN is required}"
: "${DBSERVER_ID:?DBSERVER_ID is required}"

PAYLOAD="AES_ENCRYPTION_TEST_$(date +%s)"

echo "Testing AES encryption for DB server: $DBSERVER_ID"

ENCRYPTED=$(curl -s -X POST "$AES_ENDPOINT/encrypt" \
  -H "Authorization: Bearer $AES_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"dbserver_id\":\"$DBSERVER_ID\",\"payload\":\"$PAYLOAD\"}" \
  | jq -r '.encrypted')

if [[ -z "$ENCRYPTED" ]]; then
  echo "ERROR: Encryption failed"
  exit 1
fi

DECRYPTED=$(curl -s -X POST "$AES_ENDPOINT/decrypt" \
  -H "Authorization: Bearer $AES_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"dbserver_id\":\"$DBSERVER_ID\",\"payload\":\"$ENCRYPTED\"}" \
  | jq -r '.decrypted')

if [[ "$DECRYPTED" != "$PAYLOAD" ]]; then
  echo "ERROR: Round‑trip encryption test failed"
  exit 1
fi

echo "AES encryption test successful"
