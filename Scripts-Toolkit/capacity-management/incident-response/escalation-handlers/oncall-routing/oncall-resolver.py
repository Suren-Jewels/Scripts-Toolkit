oncall-routing/
    -> oncall-resolver.py
    ->
#!/usr/bin/env python3
"""
Capability: Resolve the correct on-call target based on severity.
Outputs:
    - team name
    - escalation path
"""

import json
import os
import sys

SEVERITY = os.environ.get("SEVERITY", "NONE")

ROUTING_TABLE = {
    "CRITICAL": "primary-oncall",
    "MAJOR": "secondary-oncall",
    "MODERATE": "tertiary-oncall",
    "NONE": "no-routing"
}

team = ROUTING_TABLE.get(SEVERITY, "no-routing")

print(team)
