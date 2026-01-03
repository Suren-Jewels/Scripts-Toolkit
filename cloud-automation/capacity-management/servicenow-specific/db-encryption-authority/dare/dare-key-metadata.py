#!/usr/bin/env python3
"""
Capability: Retrieve DARE key metadata for DB server encryption validation.
Fetches:
- Key ID
- Key version
- Rotation timestamp
- Status (active/retired)
"""

import os
import requests
import json

DARE_ENDPOINT = os.environ.get("DARE_ENDPOINT")
DARE_TOKEN = os.environ.get("DARE_TOKEN")
DBSERVER_ID = os.environ.get("DBSERVER_ID")

if not DARE_ENDPOINT or not DARE_TOKEN or not DBSERVER_ID:
    raise SystemExit("DARE_ENDPOINT, DARE_TOKEN, and DBSERVER_ID are required environment variables.")

headers = {
    "Authorization": f"Bearer {DARE_TOKEN}",
    "Content-Type": "application/json"
}

url = f"{DARE_ENDPOINT}/keys/metadata/{DBSERVER_ID}"

response = requests.get(url, headers=headers)
response.raise_for_status()

metadata = response.json()

print(json.dumps(metadata, indent=2))
