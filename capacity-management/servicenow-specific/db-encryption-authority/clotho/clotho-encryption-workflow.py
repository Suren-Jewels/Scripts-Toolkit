#!/usr/bin/env python3
"""
Capability: Retrieve Clotho encryption workflow state for DB server.
Fetches:
- Workflow stage
- Key association
- Pending tasks
- Blockers
- Timestamps
"""

import os
import requests
import json

CLOTHO_ENDPOINT = os.environ.get("CLOTHO_ENDPOINT")
CLOTHO_TOKEN = os.environ.get("CLOTHO_TOKEN")
DBSERVER_ID = os.environ.get("DBSERVER_ID")

if not CLOTHO_ENDPOINT or not CLOTHO_TOKEN or not DBSERVER_ID:
    raise SystemExit("CLOTHO_ENDPOINT, CLOTHO_TOKEN, and DBSERVER_ID are required environment variables.")

headers = {
    "Authorization": f"Bearer {CLOTHO_TOKEN}",
    "Content-Type": "application/json"
}

url = f"{CLOTHO_ENDPOINT}/workflow/encryption/{DBSERVER_ID}"

response = requests.get(url, headers=headers)
response.raise_for_status()

workflow = response.json()

print(json.dumps(workflow, indent=2))
