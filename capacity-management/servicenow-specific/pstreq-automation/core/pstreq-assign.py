#!/usr/bin/env python3
"""
Capability: Assign a PSTREQ to a user or assignment group in ServiceNow.
Performs:
- Required field validation
- PATCH update to assignment fields
- Returns updated assignment info
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

PSTREQ_SYS_ID = os.environ.get("PSTREQ_SYS_ID")
ASSIGN_TO = os.environ.get("PSTREQ_ASSIGN_TO")              # user sys_id
ASSIGNMENT_GROUP = os.environ.get("PSTREQ_ASSIGN_GROUP")    # group sys_id

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if not ASSIGN_TO and not ASSIGNMENT_GROUP:
    raise SystemExit("Either PSTREQ_ASSIGN_TO or PSTREQ_ASSIGN_GROUP must be provided.")

payload = {}
if ASSIGN_TO:
    payload["assigned_to"] = ASSIGN_TO
if ASSIGNMENT_GROUP:
    payload["assignment_group"] = ASSIGNMENT_GROUP

url = f"https://{SN_INSTANCE}.service-now.com/api/now/table/u_pstreq/{PSTREQ_SYS_ID}"

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
    "assigned_to": result.get("assigned_to"),
    "assignment_group": result.get("assignment_group")
}, indent=2))
