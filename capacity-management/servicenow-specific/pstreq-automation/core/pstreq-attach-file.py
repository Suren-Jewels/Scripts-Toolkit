#!/usr/bin/env python3
"""
Capability: Attach a file to an existing PSTREQ in ServiceNow.
Performs:
- Required field validation
- File upload via attachment API
- Returns attachment sys_id
"""

import os
import requests

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
ATTACHMENT_PATH = os.environ.get("PSTREQ_ATTACHMENT_PATH")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if not ATTACHMENT_PATH or not os.path.isfile(ATTACHMENT_PATH):
    raise SystemExit("PSTREQ_ATTACHMENT_PATH must point to a valid file.")

url = f"https://{SN_INSTANCE}.service-now.com/api/now/attachment/file"
params = {
    "table_name": "u_pstreq",
    "table_sys_id": PSTREQ_SYS_ID,
    "file_name": os.path.basename(ATTACHMENT_PATH)
}

with open(ATTACHMENT_PATH, "rb") as f:
    response = requests.post(
        url,
        auth=(SN_USER, SN_PASS),
        files={"file": f},
        params=params
    )

response.raise_for_status()
result = response.json().get("result", {})

print({
    "attachment_sys_id": result.get("sys_id"),
    "file_name": os.path.basename(ATTACHMENT_PATH),
    "pstreq_sys_id": PSTREQ_SYS_ID
})
