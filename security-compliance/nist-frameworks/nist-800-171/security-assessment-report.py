#!/usr/bin/env python3
"""
Security Assessment Report Generator for NIST 800-171

Takes:
- Control map (nist-800-171-control-map.json)
- Compliance results (e.g., from nist-800-171-compliance-check.py)
- Optional metadata (system name, assessor, date)

Generates:
- A markdown report summarizing compliance posture.
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, List


def configure_logging(verbosity: int) -> None:
    """
    Configure logging verbosity.
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


def write_report(
    output_path: Path,
    metadata: Dict,
    control_map: Dict,
    compliant_controls: List[str],
    missing_controls: List[str],
    extra_controls: List[str],
) -> None:
    """
    Generate and write a markdown report file.
    """
    system_name = metadata.get("system_name", "UNKNOWN-SYSTEM")
    assessor = metadata.get("assessor", "UNKNOWN-ASSESSOR")
    assessment_date = metadata.get("assessment_date", "UNKNOWN-DATE")

    logging.debug("Writing report to: %s", output_path)

    with output_path.open("w", encoding="utf-8") as f:
        f.write(f"# NIST 800-171 Security Assessment Report\n\n")
        f.write(f"**System:** {system_name}\n\n")
        f.write(f"**Assessor:** {assessor}\n\n")
        f.write(f"**Assessment Date:** {assessment_date}\n\n")

        f.write("## Summary\n\n")
        f.write(f"- Total evaluated controls: {len(compliant_controls) + len(missing_controls)}\n")
        f.write(f"- Compliant controls: {len(compliant_controls)}\n")
        f.write(f"- Missing controls: {len(missing_controls)}\n")
        f.write(f"- Extra controls (beyond scope): {len(extra_controls)}\n\n")

        f.write("## Compliant Controls\n\n")
        if compliant_controls:
            for cid in compliant_controls:
                meta = control_map.get("controls", {}).get(cid, {})
                name = meta.get("name", "Unknown control")
                family = meta.get("family", "Unknown family")
                f.write(f"- **{cid}** ({family}): {name}\n")
        else:
            f.write("_None_\n")
        f.write("\n")

        f.write("## Missing Controls\n\n")
        if missing_controls:
            for cid in missing_controls:
                meta = control_map.get("controls", {}).get(cid, {})
                name = meta.get("name", "Unknown control")
                family = meta.get("family", "Unknown family")
                f.write(f"- **{cid}** ({family}): {name}\n")
        else:
            f.write("_None_\n")
        f.write("\n")

        f.write("## Extra Controls (Implemented but Not in Evaluated Set)\n\n")
        if extra_controls:
            for cid in extra_controls:
                meta = control_map.get("controls", {}).get(cid, {})
                name = meta.get("name", "Unknown control")
                family = meta.get("family", "Unknown family")
                f.write(f"- **{cid}** ({family}): {name}\n")
        else:
            f.write("_None_\n")
        f.write("\n")

        f.write("> Note: This is a synthetic, automation-friendly report format intended for internal use.\n")

    logging.info("Report written to %s", output_path)


def parse_arguments() -> argparse.Namespace:
    """
    Parse CLI arguments.
    """
    parser = argparse.ArgumentParser(
        description="Generate NIST 800-171 security assessment report."
    )
    parser.add_argument(
        "--control-map",
        required=True,
        help="Path to nist-800-171-control-map.json",
    )
    parser.add_argument(
        "--results",
        required=True,
        help=(
            "Path to JSON file with compliance results containing "
            "'compliant', 'missing', and 'extra' control lists."
        ),
    )
    parser.add_argument(
        "--metadata",
        required=False,
        help="Optional metadata JSON (system_name, assessor, assessment_date).",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Output report path (e.g., assessment-report.md).",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity level (-v, -vv).",
    )
    return parser.parse_args()


def main() -> None:
    """
    Main entrypoint for report generation.
    """
    args = parse_arguments()
    configure_logging(args.verbose)

    control_map_path = Path(args.control_map)
    results_path = Path(args.results)
    output_path = Path(args.output)
    metadata_path = Path(args.metadata) if args.metadata else None

    try:
        control_map = load_json(control_map_path)
        results = load_json(results_path)

        metadata: Dict = {}
        if metadata_path:
            metadata = load_json(metadata_path)

        compliant_controls = results.get("compliant", [])
        missing_controls = results.get("missing", [])
        extra_controls = results.get("extra", [])

        if not isinstance(compliant_controls, list) or not isinstance(missing_controls, list):
            raise TypeError("Result file must contain 'compliant' and 'missing' lists.")

        write_report(
            output_path=output_path,
            metadata=metadata,
            control_map=control_map,
            compliant_controls=compliant_controls,
            missing_controls=missing_controls,
            extra_controls=extra_controls,
        )

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, TypeError, ValueError) as exc:
        logging.exception("Failed to generate assessment report: %s", exc)
        print(f"[ERROR] Failed to generate assessment report: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
