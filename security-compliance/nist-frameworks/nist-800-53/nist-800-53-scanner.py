#!/usr/bin/env python3
"""
NIST 800-53 Compliance Scanner

This script evaluates a system's implemented controls against:
- A NIST 800-53 control catalog (control-catalog.json)
- A selected baseline (baseline-low-moderate-high.yaml)

It expects a machine-readable implementation file describing controls implemented
on the target system and reports:
- Implemented & required
- Required but missing
- Implemented but not required (extra)

Production-ready features:
- Argument parsing
- Structured error handling
- Clear logging
- No hardcoded sensitive data
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, List, Tuple

import yaml  # type: ignore[import-untyped]


def configure_logging(verbosity: int) -> None:
    """
    Configure logging level and format based on verbosity flag.
    """
    level = logging.WARNING
    if verbosity == 1:
        level = logging.INFO
    elif verbosity >= 2:
        level = logging.DEBUG

    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )


def load_json_file(path: Path) -> Dict:
    """
    Load a JSON file into a dictionary with basic error handling.
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


def load_yaml_file(path: Path) -> Dict:
    """
    Load a YAML file into a dictionary with basic error handling.
    """
    if not path.exists():
        logging.error("YAML file not found: %s", path)
        raise FileNotFoundError(f"YAML file not found: {path}")

    try:
        with path.open("r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        logging.debug("Loaded YAML file: %s", path)
        return data
    except yaml.YAMLError as exc:
        logging.error("Invalid YAML in file %s: %s", path, exc)
        raise


def resolve_baseline_controls(
    baselines: Dict, baseline_level: str
) -> List[str]:
    """
    Resolve the list of controls for the requested baseline level.
    """
    baseline_level_upper = baseline_level.upper()
    baseline_entry = baselines.get("baselines", {}).get(baseline_level_upper)

    if baseline_entry is None:
        logging.error("Baseline level '%s' not found.", baseline_level_upper)
        raise ValueError(f"Baseline level '{baseline_level_upper}' not defined.")

    controls = baseline_entry.get("controls", [])
    logging.debug(
        "Resolved %d controls for baseline level %s",
        len(controls),
        baseline_level_upper,
    )
    return controls


def compare_controls(
    required_controls: List[str],
    implemented_controls: List[str],
) -> Tuple[List[str], List[str], List[str]]:
    """
    Compare required vs implemented controls.

    Returns lists of:
    - compliant_controls: required and implemented
    - missing_controls: required but not implemented
    - extra_controls: implemented but not required
    """
    required_set = set(required_controls)
    implemented_set = set(implemented_controls)

    compliant_controls = sorted(required_set & implemented_set)
    missing_controls = sorted(required_set - implemented_set)
    extra_controls = sorted(implemented_set - required_set)

    logging.debug(
        "Comparison result: %d compliant, %d missing, %d extra",
        len(compliant_controls),
        len(missing_controls),
        len(extra_controls),
    )

    return compliant_controls, missing_controls, extra_controls


def parse_arguments() -> argparse.Namespace:
    """
    Parse CLI arguments.
    """
    parser = argparse.ArgumentParser(
        description="NIST 800-53 compliance scanner."
    )
    parser.add_argument(
        "--catalog",
        required=True,
        help="Path to control-catalog.json",
    )
    parser.add_argument(
        "--baseline",
        required=True,
        help="Path to baseline-low-moderate-high.yaml",
    )
    parser.add_argument(
        "--baseline-level",
        required=True,
        choices=["LOW", "MODERATE", "HIGH", "low", "moderate", "high"],
        help="Baseline level to evaluate (LOW, MODERATE, HIGH).",
    )
    parser.add_argument(
        "--implemented",
        required=True,
        help="Path to implemented-controls.json (system implementation description).",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (use -v, -vv for more detail).",
    )
    return parser.parse_args()


def main() -> None:
    """
    Main entry point for the scanner.
    """
    args = parse_arguments()
    configure_logging(args.verbose)

    catalog_path = Path(args.catalog)
    baseline_path = Path(args.baseline)
    implemented_path = Path(args.implemented)

    try:
        control_catalog = load_json_file(catalog_path)
        baselines = load_yaml_file(baseline_path)
        system_implementation = load_json_file(implemented_path)

        required_controls = resolve_baseline_controls(
            baselines=baselines,
            baseline_level=args.baseline_level,
        )

        # Expect implemented controls as a simple list under "controls"
        implemented_controls = system_implementation.get("controls", [])
        if not isinstance(implemented_controls, list):
            logging.error("Field 'controls' in implemented JSON must be a list.")
            raise TypeError("Implemented controls must be a list of control IDs.")

        compliant, missing, extra = compare_controls(
            required_controls=required_controls,
            implemented_controls=implemented_controls,
        )

        print("[RESULT] NIST 800-53 Compliance Scan")
        print(f"Baseline level: {args.baseline_level.upper()}")
        print(f"Total required controls: {len(required_controls)}")
        print(f"Compliant controls: {len(compliant)}")
        print(f"Missing controls: {len(missing)}")
        print(f"Extra controls: {len(extra)}")
        print()

        if missing:
            print("Missing controls:")
            for control_id in missing:
                metadata = control_catalog.get("controls", {}).get(control_id, {})
                title = metadata.get("title", "Unknown title")
                print(f" - {control_id}: {title}")
            print()

        if extra:
            print("Extra (implemented but not required) controls:")
            for control_id in extra:
                metadata = control_catalog.get("controls", {}).get(control_id, {})
                title = metadata.get("title", "Unknown title")
                print(f" - {control_id}: {title}")
            print()

        # Exit code reflects compliance state
        if missing:
            logging.info("Compliance check completed with missing controls.")
            sys.exit(2)

        logging.info("System is compliant with the selected baseline.")
        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, yaml.YAMLError, TypeError, ValueError) as exc:
        logging.exception("Compliance scan failed: %s", exc)
        print(f"[ERROR] Compliance scan failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
