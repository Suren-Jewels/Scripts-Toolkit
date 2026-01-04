#!/usr/bin/env python3
"""
Categorize System (FIPS 199)

Automates FIPS 199 impact categorization based on:
- Confidentiality impact
- Integrity impact
- Availability impact

Each impact can be: LOW, MODERATE, HIGH.

The script:
- Reads inputs via CLI or JSON config
- Computes the overall FIPS 199 impact level
- Outputs a summary suitable for RMF Step 1 (Categorize)
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, Any


VALID_IMPACT_LEVELS = ["LOW", "MODERATE", "HIGH"]


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


def load_json(path: Path) -> Dict[str, Any]:
    """Load JSON configuration with error handling."""
    if not path.exists():
        logging.error("JSON file not found: %s", path)
        raise FileNotFoundError(f"JSON file not found: {path}")

    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        logging.debug("Loaded JSON file: %s", path)
        return data or {}
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in file %s: %s", path, exc)
        raise


def normalize_impact(value: str) -> str:
    """Normalize impact string to uppercase and validate."""
    normalized = value.strip().upper()
    if normalized not in VALID_IMPACT_LEVELS:
        raise ValueError(f"Invalid impact level: {value}")
    return normalized


def compute_overall_impact(conf: str, integ: str, avail: str) -> str:
    """
    Compute overall FIPS 199 impact as the highest of C/I/A.

    LOW < MODERATE < HIGH
    """
    order = {"LOW": 1, "MODERATE": 2, "HIGH": 3}
    impacts = [conf, integ, avail]
    overall = max(impacts, key=lambda x: order[x])
    logging.debug(
        "Computed overall impact: C=%s, I=%s, A=%s -> %s", conf, integ, avail, overall
    )
    return overall


def parse_arguments() -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description="FIPS 199 system categorization automation."
    )
    parser.add_argument(
        "--config",
        help="Optional JSON config with 'confidentiality', 'integrity', 'availability'.",
    )
    parser.add_argument(
        "--confidentiality",
        help="Confidentiality impact (LOW, MODERATE, HIGH).",
    )
    parser.add_argument(
        "--integrity",
        help="Integrity impact (LOW, MODERATE, HIGH).",
    )
    parser.add_argument(
        "--availability",
        help="Availability impact (LOW, MODERATE, HIGH).",
    )
    parser.add_argument(
        "--system-id",
        required=False,
        help="System identifier for reporting context.",
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

    conf = args.confidentiality
    integ = args.integrity
    avail = args.availability

    try:
        # If config is supplied, use it to fill missing values
        if args.config:
            cfg = load_json(Path(args.config))
            conf = conf or cfg.get("confidentiality")
            integ = integ or cfg.get("integrity")
            avail = avail or cfg.get("availability")

        if not (conf and integ and avail):
            raise ValueError(
                "Confidentiality, Integrity, and Availability impacts must be provided "
                "either via CLI or config."
            )

        conf_n = normalize_impact(conf)
        integ_n = normalize_impact(integ)
        avail_n = normalize_impact(avail)

        overall = compute_overall_impact(conf_n, integ_n, avail_n)

        system_id = args.system_id or "UNKNOWN-SYSTEM"

        print("[RESULT] FIPS 199 System Categorization")
        print(f"System ID: {system_id}")
        print(f"Confidentiality: {conf_n}")
        print(f"Integrity:      {integ_n}")
        print(f"Availability:   {avail_n}")
        print(f"Overall Impact: {overall}")

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, ValueError) as exc:
        logging.exception("System categorization failed: %s", exc)
        print(f"[ERROR] System categorization failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
