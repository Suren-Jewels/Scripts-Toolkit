#!/usr/bin/env bash
# Encryption Validator
# Validates that only FIPS‑compatible ciphers are configured.
# Expects a simple config file listing ciphers, one per line.

set -euo pipefail

CONFIG_FILE="ciphers.conf"

usage() {
    echo "Usage: $0 --config <ciphers.conf>"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config) CONFIG_FILE="$2"; shift 2 ;;
        *) usage ;;
    esac
done

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_FILE"
    exit 1
fi

# Example allowed list (simplified, illustrative)
ALLOWED_CIPHERS=(
  "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
  "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
)

is_allowed() {
    local cipher="$1"
    for ac in "${ALLOWED_CIPHERS[@]}"; do
        if [[ "$ac" == "$cipher" ]]; then
            return 0
        fi
    done
    return 1
}

INVALID=0

echo "[INFO] Validating configured ciphers in $CONFIG_FILE"

while IFS= read -r line; do
    cipher="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$cipher" ]] && continue
    is_allowed "$cipher" || {
        echo "[WARN] Non‑approved cipher detected: $cipher"
        INVALID=$((INVALID+1))
    }
done < "$CONFIG_FILE"

if [[ "$INVALID" -gt 0 ]]; then
    echo "[RESULT] Encryption validation completed with WARNINGS ($INVALID non‑approved ciphers)."
    exit 2
else
    echo "[RESULT] All configured ciphers are in the approved list."
    exit 0
fi
