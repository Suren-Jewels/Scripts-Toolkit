#!/usr/bin/env python3
"""
Capability: Close an existing PSTREQ in ServiceNow.
Performs:
- Required field validation
- State update to 'Closed'
- Optional closure notes
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
CLOSE_NOTES = os.environ.get("PSTREQ_CLOSE_NOTES", "")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/u_pstreq/{PSTREQ_SYS_ID}"

payload = {
    "state": "Closed",
    "close_notes": CLOSE_NOTES
}

response = requests.patch(
    url,
    auth=(SN_USER, SN_PASS),
    headers={"Content-Type": "application/json"},
    data=json.dumps(payload)
)

response.raise_for_status()
result = response.json().get("result", {})

print(json.dumps({
    "pstreq_sys_id": result.get("sys_id"),
    "state": result.get("state"),
    "close_notes": CLOSE_NOTES
}, indent=2))
