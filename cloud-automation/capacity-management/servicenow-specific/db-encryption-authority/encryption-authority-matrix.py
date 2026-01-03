#!/usr/bin/env python3
"""
Capability: Build a unified encryption authority matrix for a DB server.
Aggregates:
- DARE key metadata
- Clotho workflow metadata
- AES key metadata
Outputs a consolidated matrix for alignment and mismatch detection.
"""

import os
import requests
import json

DBSERVER_ID = os.environ.get("DBSERVER_ID")

DARE_ENDPOINT = os.environ.get("DARE_ENDPOINT")
DARE_TOKEN = os.environ.get("DARE_TOKEN")

CLOTHO_ENDPOINT = os.environ.get("CLOTHO_ENDPOINT")
CLOTHO_TOKEN = os.environ.get("CLOTHO_TOKEN")

AES_ENDPOINT = os.environ.get("AES_ENDPOINT")
AES_TOKEN = os.environ.get("AES_TOKEN")

if not DBSERVER_ID:
    raise SystemExit("DBSERVER_ID is required.")

if not all([DARE_ENDPOINT, DARE_TOKEN, CLOTHO_ENDPOINT, CLOTHO_TOKEN, AES_ENDPOINT, AES_TOKEN]):
    raise SystemExit("All encryption authority endpoints and tokens must be set.")

def fetch(url, token):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    r = requests.get(url, headers=headers)
    r.raise_for_status()
    return r.json()

matrix = {
    "dbserver_id": DBSERVER_ID,
    "dare": fetch(f"{DARE_ENDPOINT}/keys/metadata/{DBSERVER_ID}", DARE_TOKEN),
    "clotho": fetch(f"{CLOTHO_ENDPOINT}/workflow/encryption/{DBSERVER_ID}", CLOTHO_TOKEN),
    "aes": fetch(f"{AES_ENDPOINT}/keys/metadata/{DBSERVER_ID}", AES_TOKEN)
}

print(json.dumps(matrix, indent=2))
