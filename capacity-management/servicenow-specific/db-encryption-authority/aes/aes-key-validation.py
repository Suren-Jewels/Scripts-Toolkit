#!/usr/bin/env python3
"""
Capability: Retrieve AES key metadata for DB server encryption validation.
Fetches:
- Key ID
- Key version
- Rotation timestamp
- Status (active/retired)
"""

import os
import requests
import json

AES_ENDPOINT = os.environ.get("AES_ENDPOINT")
AES_TOKEN = os.environ.get("AES_TOKEN")
DBSERVER_ID = os.environ.get("DBSERVER_ID")

if not AES_ENDPOINT or not AES_TOKEN or not DBSERVER_ID:
    raise SystemExit("AES_ENDPOINT, AES_TOKEN, and DBSERVER_ID are required environment variables.")

headers = {
    "Authorization": f"Bearer {AES_TOKEN}",
    "Content-Type": "application/json"
}

url = f"{AES_ENDPOINT}/keys/metadata/{DBSERVER_ID}"

response = requests.get(url, headers=headers)
response.raise_for_status()

metadata = response.json()

print(json.dumps(metadata, indent=2))
