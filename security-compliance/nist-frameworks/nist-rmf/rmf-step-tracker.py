#!/usr/bin/env python3
"""
RMF Step Tracker

Tracks progress through the NIST Risk Management Framework (RMF) 6-step process:
1. Categorize
2. Select
3. Implement
4. Assess
5. Authorize
6. Monitor

The tracker uses a JSON state file to:
- Record current step
- Track timestamps and status per step
- Provide a summary of RMF progress

State file example (rmf-state.json):

{
  "system_id": "SYSTEM-123",
  "steps": {
    "1-Categorize": { "status": "COMPLETED", "timestamp": "2025-01-01T12:00:00Z" },
    "2-Select": { "status": "IN_PROGRESS", "timestamp": "2025-01-10T14:30:00Z" }
  },
  "current_step": "2-Select"
}
"""

import argparse
import json
import logging
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any


RMF_STEPS = [
    "1-Categorize",
    "2-Select",
    "3-Implement",
    "4-Assess",
    "5-Authorize",
    "6-Monitor",
]


def configure_logging(verbosity: int) -> None:
    """Configure logging verbosity."""
    if verbosity <= 0:
        level = logging.WARNING
    elif verbosity == 1:
        level = logging.INFO
    else:
        level = logging.DEBUG

    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )


def load_state(path: Path) -> Dict[str, Any]:
    """Load RMF state from JSON; return empty skeleton if file does not exist."""
    if not path.exists():
        logging.info("State file not found, starting with empty state: %s", path)
        return {
            "system_id": "UNKNOWN",
            "steps": {},
            "current_step": None,
        }

    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        logging.debug("Loaded RMF state from %s", path)
        return data
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in state file %s: %s", path, exc)
        raise


def save_state(path: Path, state: Dict[str, Any]) -> None:
    """Persist RMF state to JSON."""
    path.write_text(json.dumps(state, indent=2), encoding="utf-8")
    logging.debug("Saved RMF state to %s", path)


def timestamp_utc() -> str:
    """Generate an ISO 8601 UTC timestamp."""
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def set_step_status(
    state: Dict[str, Any],
    step_name: str,
    status: str,
) -> None:
    """
    Update the status of a specific RMF step.

    Valid statuses (suggested): NOT_STARTED, IN_PROGRESS, BLOCKED, COMPLETED.
    """
    if step_name not in RMF_STEPS:
        raise ValueError(f"Invalid RMF step: {step_name}")

    if "steps" not in state or not isinstance(state["steps"], dict):
        state["steps"] = {}

    state["steps"].setdefault(step_name, {})
    state["steps"][step_name]["status"] = status
    state["steps"][step_name]["timestamp"] = timestamp_utc()
    state["current_step"] = step_name

    logging.info("Updated step '%s' to status '%s'", step_name, status)


def summarize_state(state: Dict[str, Any]) -> None:
    """Print a human-readable summary of RMF progress."""
    print("[RESULT] RMF 6-Step Process Status")
    print(f"System ID: {state.get('system_id', 'UNKNOWN')}")
    print(f"Current Step: {state.get('current_step', 'N/A')}")
    print()

    steps_info = state.get("steps", {})
    for step in RMF_STEPS:
        info = steps_info.get(step, {})
        status = info.get("status", "NOT_STARTED")
        ts = info.get("timestamp", "N/A")
        print(f" - {step}: {status} (last updated: {ts})")


def parse_arguments() -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description="Track progress through the NIST RMF 6-step process."
    )
    parser.add_argument(
        "--state-file",
        required=True,
        help="Path to RMF state file (JSON).",
    )
    parser.add_argument(
        "--system-id",
        required=False,
        help="Optional system identifier (set on new state or override existing).",
    )
    parser.add_argument(
        "--set-step",
        choices=RMF_STEPS,
        help="Set status for a specific step (requires --status).",
    )
    parser.add_argument(
        "--status",
        choices=["NOT_STARTED", "IN_PROGRESS", "BLOCKED", "COMPLETED"],
        help="Status to set for --set-step.",
    )
    parser.add_argument(
        "--show",
        action="store_true",
        help="Show current RMF state summary.",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (-v, -vv).",
    )
    return parser.parse_args()


def main() -> None:
    """Main entrypoint."""
    args = parse_arguments()
    configure_logging(args.verbose)

    state_path = Path(args.state_file)

    try:
        state = load_state(state_path)

        # Optionally set system ID
        if args.system_id:
            logging.info("Setting system_id to %s", args.system_id)
            state["system_id"] = args.system_id

        # Optionally update a step
        if args.set_step:
            if not args.status:
                raise ValueError("--status is required when using --set-step.")
            set_step_status(state, args.set_step, args.status)

        # Save any changes
        save_state(state_path, state)

        # Show summary if requested or if no other action specified
        if args.show or (not args.set_step and not args.system_id):
            summarize_state(state)

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, ValueError) as exc:
        logging.exception("RMF step tracking failed: %s", exc)
        print(f"[ERROR] RMF step tracking failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
