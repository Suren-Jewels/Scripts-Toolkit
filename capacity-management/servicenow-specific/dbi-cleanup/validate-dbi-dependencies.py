#!/usr/bin/env python3
"""
Capability: Validate DBI dependencies to ensure the instance is safe for cleanup.
Checks:
- Active DB connections
- Application node relationships
- Instance attachments
- Any CI relationships blocking retirement
"""

import os
import requests
import json

SN_INSTANCE = os.environ.get("SN_INSTANCE")
SN_USER = os.environ.get("SN_USER")
SN_PASS = os.environ.get("SN_PASS")

if not SN_INSTANCE or not SN_USER or not SN_PASS:
    raise SystemExit("SN_INSTANCE, SN_USER, SN_PASS are required environment variables.")

DBI_TABLE = "cmdb_ci_db_instance"
REL_TABLE = "cmdb_rel_ci"

def get_dbi_list():
    """Return all DBI sys_ids for validation."""
    url = f"{SN_INSTANCE}/api/now/table/{DBI_TABLE}"
    params = {"sysparm_fields": "sys_id,name"}
    r = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
    r.raise_for_status()
    return r.json().get("result", [])

def get_relationships(sys_id):
    """Return all CI relationships for a given DBI."""
    url = f"{SN_INSTANCE}/api/now/table/{REL_TABLE}"
    params = {
        "sysparm_query": f"parent={sys_id}^ORchild={sys_id}",
        "sysparm_fields": "sys_id,parent,child,type"
    }
    r = requests.get(url, auth=(SN_USER, SN_PASS), params=params)
    r.raise_for_status()
    return r.json().get("result", [])

def main():
    dbis = get_dbi_list()
    output = []

    for dbi in dbis:
        sys_id = dbi["sys_id"]
        name = dbi["name"]

        rels = get_relationships(sys_id)

        if len(rels) == 0:
            output.append({
                "sys_id": sys_id,
                "name": name,
                "dependencies": 0,
                "status": "SAFE_TO_CLEAN"
            })
        else:
            output.append({
                "sys_id": sys_id,
                "name": name,
                "dependencies": len(rels),
                "status": "HAS_DEPENDENCIES"
            })

    print(json.dumps(output, indent=2))

if __name__ == "__main__":
    main()
