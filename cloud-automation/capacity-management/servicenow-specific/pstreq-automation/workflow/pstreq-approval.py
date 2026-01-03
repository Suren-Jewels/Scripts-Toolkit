#!/usr/bin/env python3
"""
Capability: Approve or reject a PSTREQ in ServiceNow.
Performs:
- Required field validation
- Approval action via POST
- Returns approval state
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
APPROVAL_ACTION = os.environ.get("PSTREQ_APPROVAL_ACTION")  # "approve" or "reject"

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if APPROVAL_ACTION not in ["approve", "reject"]:
    raise SystemExit("PSTREQ_APPROVAL_ACTION must be 'approve' or 'reject'.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/sysapproval_approver"

payload = {
    "document_id": PSTREQ_SYS_ID,
    "state": "approved" if APPROVAL_ACTION == "approve" else "rejected"
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
    "pstreq_sys_id": PSTREQ_SYS_ID,
    "approval_state": payload["state"]
}, indent=2))
