#!/usr/bin/env python3
"""
NIST 800-171 Compliance Checker

Validates a system's implementation against a subset or full set
of NIST 800-171 controls using:

- A control map (nist-800-171-control-map.json)
- An implementation description (implemented-controls.json)

Outputs:
- Compliant controls
- Missing controls
- Extra (implemented but not required) controls

Production-ready features:
- Argument parsing
- Structured logging
- Error handling
- No hardcoded sensitive data
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, List, Tuple


def configure_logging(verbosity: int) -> None:
    """
    Configure logging based on verbosity.
    - 0: WARNING
    - 1: INFO
    - 2+: DEBUG
    """
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


def load_json(path: Path) -> Dict:
    """
    Load JSON file with error handling.
    """
    if not path.exists():
        logging.error("JSON file not found: %s", path)
        raise FileNotFoundError(f"JSON file not found: {path}")

    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        logging.debug("Loaded JSON file: %s", path)
        return data
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in file %s: %s", path, exc)
        raise


def compare_controls(
    required_controls: List[str],
    implemented_controls: List[str],
) -> Tuple[List[str], List[str], List[str]]:
    """
    Compare required vs implemented controls and return:
    - compliant: required & implemented
    - missing: required but not implemented
    - extra: implemented but not required
    """
    required_set = set(required_controls)
    implemented_set = set(implemented_controls)

    compliant = sorted(required_set & implemented_set)
    missing = sorted(required_set - implemented_set)
    extra = sorted(implemented_set - required_set)

    logging.debug(
        "Comparison results: %d compliant, %d missing, %d extra",
        len(compliant),
        len(missing),
        len(extra),
    )

    return compliant, missing, extra


def parse_arguments() -> argparse.Namespace:
    """
    Parse CLI arguments.
    """
    parser = argparse.ArgumentParser(
        description="NIST 800-171 compliance checker."
    )
    parser.add_argument(
        "--control-map",
        required=True,
        help="Path to nist-800-171-control-map.json.",
    )
    parser.add_argument(
        "--implemented",
        required=True,
        help="Path to implemented-controls.json describing system implementation.",
    )
    parser.add_argument(
        "--subset",
        required=False,
        nargs="*",
        help=(
            "Optional subset of control IDs to check (e.g., 3.1.1 3.1.2). "
            "If omitted, all controls from the control map are used."
        ),
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
    """
    Main entrypoint for the NIST 800-171 compliance checker.
    """
    args = parse_arguments()
    configure_logging(args.verbose)

    control_map_path = Path(args.control_map)
    implemented_path = Path(args.implemented)

    try:
        control_map = load_json(control_map_path)
        implemented = load_json(implemented_path)

        # All control IDs from the map
        map_controls = list(control_map.get("controls", {}).keys())
        if not map_controls:
            logging.error("No controls defined in control map.")
            raise ValueError("Control map contains no controls.")

        # Determine required control set (all or subset)
        if args.subset:
            required_controls = args.subset
            logging.info("Using subset of controls: %d", len(required_controls))
        else:
            required_controls = map_controls
            logging.info("Using full control set: %d controls", len(required_controls))

        # Expect a list under "controls" in implemented JSON
        implemented_controls = implemented.get("controls", [])
        if not isinstance(implemented_controls, list):
            logging.error("Field 'controls' in implemented JSON must be a list.")
            raise TypeError("Implemented controls must be a list of control IDs.")

        compliant, missing, extra = compare_controls(
            required_controls=required_controls,
            implemented_controls=implemented_controls,
        )

        print("[RESULT] NIST 800-171 Compliance Check")
        print(f"Total required controls: {len(required_controls)}")
        print(f"Compliant controls: {len(compliant)}")
        print(f"Missing controls: {len(missing)}")
        print(f"Extra controls: {len(extra)}")
        print()

        if missing:
            print("Missing controls:")
            for cid in missing:
                meta = control_map.get("controls", {}).get(cid, {})
                name = meta.get("name", "Unknown control")
                print(f" - {cid}: {name}")
            print()

        if extra:
            print("Extra controls (implemented but not required in this run):")
            for cid in extra:
                meta = control_map.get("controls", {}).get(cid, {})
                name = meta.get("name", "Unknown control")
                print(f" - {cid}: {name}")
            print()

        # Exit code signals compliance state
        if missing:
            logging.info("Compliance check completed with missing controls.")
            sys.exit(2)

        logging.info("System is compliant with the evaluated controls.")
        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, ValueError, TypeError) as exc:
        logging.exception("Compliance check failed: %s", exc)
        print(f"[ERROR] Compliance check failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
