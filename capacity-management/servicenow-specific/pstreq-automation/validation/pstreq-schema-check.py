#!/usr/bin/env python3
"""
Capability: Validate PSTREQ schema in ServiceNow.
Performs:
- Required field validation
- GET request to retrieve record
- Compares returned fields to expected schema
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")

EXPECTED_FIELDS = [
    "number",
    "short_description",
    "requested_for",
    "assignment_group",
    "assigned_to",
    "state",
    "sys_id",
    "sys_created_on",
    "sys_updated_on"
]

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/u_pstreq/{PSTREQ_SYS_ID}"

response = requests.get(
    url,
    auth=(SN_USER, SN_PASS),
    headers={"Content-Type": "application/json"}
)

response.raise_for_status()
record = response.json().get("result", {})

missing = [f for f in EXPECTED_FIELDS if f not in record]
present = [f for f in EXPECTED_FIELDS if f in record]

print(json.dumps({
    "pstreq_sys_id": PSTREQ_SYS_ID,
    "missing_fields": missing,
    "present_fields": present
}, indent=2))
