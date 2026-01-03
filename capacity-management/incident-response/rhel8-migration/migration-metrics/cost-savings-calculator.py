#!/usr/bin/env python3
# Capability: Calculate migration efficiency gains.

import sys
import json

if len(sys.argv) < 3:
    raise SystemExit("Usage: cost-savings-calculator.py <hours_saved> <hourly_cost>")

hours_saved = float(sys.argv[1])
hourly_cost = float(sys.argv[2])

savings = hours_saved * hourly_cost

print(json.dumps({
    "hours_saved": hours_saved,
    "hourly_cost": hourly_cost,
    "total_savings": savings
}, indent=2))
