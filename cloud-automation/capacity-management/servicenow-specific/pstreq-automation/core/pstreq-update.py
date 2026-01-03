#!/usr/bin/env python3
"""
Capability: Update fields on an existing PSTREQ in ServiceNow.
Performs:
- Required field validation
- PATCH request to ServiceNow
- Returns updated fields
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
PSTREQ_UPDATE_FIELDS = os.environ.get("PSTREQ_UPDATE_FIELDS")  # JSON string of fields to update

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if not PSTREQ_UPDATE_FIELDS:
    raise SystemExit("PSTREQ_UPDATE_FIELDS must contain a JSON object of fields to update.")

try:
    update_payload = json.loads(PSTREQ_UPDATE_FIELDS)
except json.JSONDecodeError:
    raise SystemExit("PSTREQ_UPDATE_FIELDS must be valid JSON.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/u_pstreq/{PSTREQ_SYS_ID}"

response = requests.patch(
    url,
    auth=(SN_USER, SN_PASS),
    headers={"Content-Type": "application/json"},
    data=json.dumps(update_payload)
)

response.raise_for_status()
result = response.json().get("result", {})

print(json.dumps({
    "sys_id": result.get("sys_id"),
    "updated_fields": update_payload
}, indent=2))
