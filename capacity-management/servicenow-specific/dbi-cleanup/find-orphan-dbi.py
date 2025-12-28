#!/usr/bin/env python3
"""
Capability: Identify orphan DBI nodes with no active instances or dependencies.
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

# Query: DBI nodes with no related instances + no dependencies
QUERY = (
    "u_active_instances=0^"
    "u_dependency_count=0^"
    "install_status!=7"  # exclude pending retire
)

url = f"{SN_INSTANCE}/api/now/table/{TABLE}"
params = {
    "sysparm_query": QUERY,
    "sysparm_fields": "sys_id,name,u_active_instances,u_dependency_count,install_status"
}

response = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
response.raise_for_status()

print(json.dumps(response.json(), indent=2))
