#!/usr/bin/env python3
# Capability: Track time-to-migrate per host.

import json
import sys
import time
import os

if len(sys.argv) < 3:
    raise SystemExit("Usage: migration-duration.py <host> <start|end>")

host = sys.argv[1]
action = sys.argv[2]

os.makedirs("metrics", exist_ok=True)
file = f"metrics/{host}-duration.json"

if action == "start":
    with open(file, "w") as f:
        json.dump({"start": time.time()}, f)
    print("Migration start time recorded.")

elif action == "end":
    if not os.path.isfile(file):
        raise SystemExit("Start time not found.")
    with open(file) as f:
        data = json.load(f)
    data["end"] = time.time()
    data["duration_seconds"] = data["end"] - data["start"]
    with open(file, "w") as f:
        json.dump(data, f, indent=2)
    print("Migration end time recorded.")

else:
    raise SystemExit("Action must be: start | end")
