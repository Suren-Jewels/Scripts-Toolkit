#!/usr/bin/env python3
"""
Capability: Compare two server lifecycle snapshots.
Produces a JSON diff showing:
- added servers
- removed servers
- changed servers (labels, capacity, allocatable, conditions, taints)
"""

import os
import json
import sys

if len(sys.argv) != 3:
    raise SystemExit("Usage: server-lifecycle-diff.py <old.json> <new.json>")

old_file = sys.argv[1]
new_file = sys.argv[2]

with open(old_file) as f:
    old = json.load(f)

with open(new_file) as f:
    new = json.load(f)

def index_by_name(items):
    return {i["name"]: i for i in items}

old_idx = index_by_name(old)
new_idx = index_by_name(new)

old_keys = set(old_idx.keys())
new_keys = set(new_idx.keys())

added = sorted(list(new_keys - old_keys))
removed = sorted(list(old_keys - new_keys))

changed = []

for key in (old_keys & new_keys):
    if old_idx[key] != new_idx[key]:
        changed.append(key)

output = {
    "added": [{"name": name} for name in added],
    "removed": [{"name": name} for name in removed],
    "changed": [{"name": name} for name in changed],
}

print(json.dumps(output, indent=2))
