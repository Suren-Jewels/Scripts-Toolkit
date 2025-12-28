#!/usr/bin/env python3
"""
Capability: Monitor the workflow execution for a DBI CI until completion.
Checks:
- Workflow state
- Success or failure
- Loop until terminal state
"""

import os
import time
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, SN_PASS are required environment variables.")

DBI_SYSID = os.environ.get("DBI_SYSID")
if not DBI_SYSID:
    raise SystemExit("DBI_SYSID environment variable is required.")

WORKFLOW_TABLE = "wf_context"

def get_workflow_state(sys_id):
    url = f"{SN_INSTANCE}/api/now/table/{WORKFLOW_TABLE}"
    params = {
        "sysparm_query": f"table_sys_id={sys_id}",
        "sysparm_fields": "sys_id,state,started,ended"
    }
    r = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
    r.raise_for_status()
    result = r.json().get("result", [])
    return result[0] if result else None

print(f"Monitoring workflow for DBI: {DBI_SYSID}")

while True:
    wf = get_workflow_state(DBI_SYSID)

    if not wf:
        print("No workflow found yet. Waiting...")
        time.sleep(5)
        continue

    state = wf.get("state")
    print(f"Workflow state: {state}")

    if state in ("completed", "terminated", "error"):
        print(json.dumps(wf, indent=2))
        break

    time.sleep(5)
