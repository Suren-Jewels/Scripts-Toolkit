#!/usr/bin/env python3
"""
Capability: Export a DBI cleanup report (JSON or CSV) from ServiceNow.
Includes:
- Name
- Sys ID
- Install status
- Discovery timestamp
- Dependency count
"""

import os
import csv
import json
import requests

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, SN_PASS are required environment variables.")

OUTPUT = os.environ.get("OUTPUT", "dbi_cleanup_report.json")
FORMAT = OUTPUT.split(".")[-1].lower()

TABLE = "cmdb_ci_db_instance"
FIELDS = (
    "sys_id,name,install_status,most_recent_discovery,"
    "u_dependency_count,sys_updated_on"
)

url = f"{SN_INSTANCE}/api/now/table/{TABLE}"
params = {"sysparm_fields": FIELDS}

response = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
response.raise_for_status()

data = response.json().get("result", [])

if FORMAT == "json":
    with open(OUTPUT, "w") as f:
        json.dump(data, f, indent=2)
    print(f"JSON report exported: {OUTPUT}")

elif FORMAT == "csv":
    with open(OUTPUT, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
    print(f"CSV report exported: {OUTPUT}")

else:
    raise SystemExit("Unsupported format. Use .json or .csv")
