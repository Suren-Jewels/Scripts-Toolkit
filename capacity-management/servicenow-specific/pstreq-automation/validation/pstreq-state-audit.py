#!/usr/bin/env python3
"""
Capability: Audit the workflow state of a PSTREQ in ServiceNow.
Performs:
- Required field validation
- GET request to retrieve record
- Validates state against expected lifecycle
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")

EXPECTED_STATES = [
    "New",
    "In Progress",
    "Pending Approval",
    "Approved",
    "Rejected",
    "Completed",
    "Closed"
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

state = record.get("state")

audit = {
    "pstreq_sys_id": PSTREQ_SYS_ID,
    "current_state": state,
    "is_valid_state": state in EXPECTED_STATES,
    "expected_states": EXPECTED_STATES
}

print(json.dumps(audit, indent=2))
