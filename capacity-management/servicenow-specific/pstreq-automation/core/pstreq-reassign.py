#!/usr/bin/env python3
"""
Capability: Reassign a PSTREQ to a new user or assignment group in ServiceNow.
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
NEW_ASSIGNED_TO = os.environ.get("PSTREQ_NEW_ASSIGNED_TO")          # user sys_id
NEW_ASSIGNMENT_GROUP = os.environ.get("PSTREQ_NEW_ASSIGN_GROUP")    # group sys_id

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, and SN_PASS are required environment variables.")

if not PSTREQ_SYS_ID:
    raise SystemExit("PSTREQ_SYS_ID is required.")

if not NEW_ASSIGNED_TO and not NEW_ASSIGNMENT_GROUP:
    raise SystemExit("Either PSTREQ_NEW_ASSIGNED_TO or PSTREQ_NEW_ASSIGN_GROUP must be provided.")

payload = {}
if NEW_ASSIGNED_TO:
    payload["assigned_to"] = NEW_ASSIGNED_TO
if NEW_ASSIGNMENT_GROUP:
    payload["assignment_group"] = NEW_ASSIGNMENT_GROUP

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
