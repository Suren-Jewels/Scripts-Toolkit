#!/usr/bin/env python3
"""
Capability: Validate DBI capacity fields to ensure the instance is safe for cleanup.
Checks:
- discovered_capacity_size
- desired_capacity_size
- capacity_state
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, SN_PASS are required environment variables.")

TABLE = "cmdb_ci_db_instance"

# Query: DBI nodes with capacity inconsistencies
QUERY = (
    "discovered_capacity_sizeISEMPTY^"
    "ORdesired_capacity_sizeISEMPTY^"
    "ORcapacity_state!=reserved"
)

url = f"{SN_INSTANCE}/api/now/table/{TABLE}"
params = {
    "sysparm_query": QUERY,
    "sysparm_fields": (
        "sys_id,name,discovered_capacity_size,"
        "desired_capacity_size,capacity_state,sys_updated_on"
    )
}

response = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
response.raise_for_status()

print(json.dumps(response.json(), indent=2))
