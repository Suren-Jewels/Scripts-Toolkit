#!/usr/bin/env python3
"""
Capability: Diff two allocation snapshots.
Produces a deterministic JSON diff showing:
- added keys
- removed keys
- changed values
"""

import os
import json
import sys

OLD_FILE = os.environ.get("OLD_ALLOC")
NEW_FILE = os.environ.get("NEW_ALLOC")

if not OLD_FILE:
    raise SystemExit("OLD_ALLOC is required.")
if not NEW_FILE:
    raise SystemExit("NEW_ALLOC is required.")

with open(OLD_FILE) as f:
    old = json.load(f)

with open(NEW_FILE) as f:
    new = json.load(f)

diff = {
    "added": {},
    "removed": {},
    "changed": {}
}

def walk(prefix, a, b):
    # Keys only in new
    for key in b.keys() - a.keys():
        diff["added"][f"{prefix}{key}"] = b[key]

    # Keys only in old
    for key in a.keys() - b.keys():
        diff["removed"][f"{prefix}{key}"] = a[key]

    # Keys in both
    for key in a.keys() & b.keys():
        path = f"{prefix}{key}"
        av = a[key]
        bv = b[key]

        if isinstance(av, dict) and isinstance(bv, dict):
            walk(path + ".", av, bv)
        else:
            if av != bv:
                diff["changed"][path] = {
                    "old": av,
                    "new": bv
                }

walk("", old, new)

print(json.dumps(diff, indent=2))
