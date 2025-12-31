#!/usr/bin/env python3
"""
Capability: Create a new PSTREQ in ServiceNow.
Performs:
- Required field validation
- POST request to ServiceNow
- Returns PSTREQ number and sys_id
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

SHORT_DESCRIPTION = os.environ.get("PSTREQ_SHORT_DESCRIPTION")
REQUESTED_FOR = os.environ.get("PSTREQ_REQUESTED_FOR")
ASSIGNMENT_GROUP = os.environ.get("PSTREQ_ASSIGNMENT_GROUP")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not SHORT_DESCRIPTION or not REQUESTED_FOR or not ASSIGNMENT_GROUP:
    raise SystemExit("PSTREQ_SHORT_DESCRIPTION, PSTREQ_REQUESTED_FOR, and PSTREQ_ASSIGNMENT_GROUP are required.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/u_pstreq"

payload = {
    "short_description": SHORT_DESCRIPTION,
    "requested_for": REQUESTED_FOR,
    "assignment_group": ASSIGNMENT_GROUP
}

response = requests.post(
    url,
    auth=(SN_USER, SN_PASS),
    headers={"Content-Type": "application/json"},
    data=json.dumps(payload)
)

response.raise_for_status()
result = response.json().get("result", {})

print(json.dumps({
    "pstreq_number": result.get("number"),
    "sys_id": result.get("sys_id")
}, indent=2))
