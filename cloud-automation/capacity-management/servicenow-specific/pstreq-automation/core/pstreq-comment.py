#!/usr/bin/env python3
"""
Capability: Add a comment to an existing PSTREQ in ServiceNow.
Performs:
- Required field validation
- POST to the journal entry API
- Returns comment sys_id
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
PSTREQ_COMMENT = os.environ.get("PSTREQ_COMMENT")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if not PSTREQ_COMMENT:
    raise SystemExit("PSTREQ_COMMENT is required.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/sys_journal_field"

payload = {
    "element_id": PSTREQ_SYS_ID,
    "element": "comments",
    "value": PSTREQ_COMMENT
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
    "comment_sys_id": result.get("sys_id"),
    "pstreq_sys_id": PSTREQ_SYS_ID
}, indent=2))
