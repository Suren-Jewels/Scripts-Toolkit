#!/usr/bin/env python3
"""
ATO Readiness Checker

Performs a lightweight Authority to Operate (ATO) readiness check based on:
- Control implementation coverage
- POA&M (Plan of Action & Milestones) status
- Documentation artifacts presence

Inputs:
- JSON configuration describing readiness indicators

Example config (ato-readiness.json):

{
  "system_id": "SYSTEM-123",
  "controls_required": 100,
  "controls_implemented": 92,
  "poam_open_items": 5,
  "poam_high_risk_items": 1,
  "documents": {
    "ssp_present": true,
    "sap_present": true,
    "sar_present": false,
    "contingency_plan_present": true
  }
}

Outputs:
- Readiness score and qualitative rating
- Quick summary for RMF Step 5 (Authorize)
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, Any


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
    """Load JSON file with error handling."""
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


def compute_readiness_score(config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Compute readiness score and rating.

    Heuristic:
    - Control coverage (0–50 points)
    - POA&M posture   (0–25 points)
    - Documentation   (0–25 points)
    """
    controls_required = int(config.get("controls_required", 0))
    controls_implemented = int(config.get("controls_implemented", 0))
    poam_open = int(config.get("poam_open_items", 0))
    poam_high = int(config.get("poam_high_risk_items", 0))
    docs = config.get("documents", {})

    # Control coverage
    control_coverage_pct = (
        (controls_implemented / controls_required) * 100
        if controls_required > 0
        else 0.0
    )
    if control_coverage_pct >= 90:
        control_score = 50
    elif control_coverage_pct >= 75:
        control_score = 35
    elif control_coverage_pct >= 60:
        control_score = 20
    else:
        control_score = 10

    # POA&M posture
    if poam_high > 0:
        poam_score = 5
    elif poam_open <= 5:
        poam_score = 25
    elif poam_open <= 15:
        poam_score = 15
    else:
        poam_score = 10

    # Documentation completeness
    doc_keys = ["ssp_present", "sap_present", "sar_present", "contingency_plan_present"]
    docs_present = sum(1 for k in doc_keys if docs.get(k, False))
    doc_score = (docs_present / len(doc_keys)) * 25

    total_score = control_score + poam_score + doc_score

    if total_score >= 80:
        rating = "HIGH"
    elif total_score >= 60:
        rating = "MEDIUM"
    else:
        rating = "LOW"

    logging.debug(
        "ATO readiness details: coverage=%.1f%%, control_score=%d, poam_score=%d, "
        "doc_score=%.1f, total_score=%.1f, rating=%s",
        control_coverage_pct,
        control_score,
        poam_score,
        doc_score,
        total_score,
        rating,
    )

    return {
        "total_score": total_score,
        "rating": rating,
        "control_coverage_pct": control_coverage_pct,
        "controls_required": controls_required,
        "controls_implemented": controls_implemented,
        "poam_open_items": poam_open,
        "poam_high_risk_items": poam_high,
        "docs_present": docs_present,
        "docs_total": len(doc_keys),
    }


def parse_arguments() -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description="ATO readiness checker for RMF."
    )
    parser.add_argument(
        "--config",
        required=True,
        help="Path to ATO readiness JSON configuration.",
    )
    parser.add_argument(
        "--output",
        required=False,
        help="Optional JSON output file for detailed readiness results.",
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

    config_path = Path(args.config)
    output_path = Path(args.output) if args.output else None

    try:
        config = load_json(config_path)
        system_id = config.get("system_id", "UNKNOWN-SYSTEM")

        results = compute_readiness_score(config)

        print("[RESULT] ATO Readiness Assessment")
        print(f"System ID: {system_id}")
        print(f"Overall Readiness Rating: {results['rating']}")
        print(f"Readiness Score: {results['total_score']:.1f} / 100")
        print(f"Control Coverage: {results['control_coverage_pct']:.1f}% "
              f"({results['controls_implemented']}/{results['controls_required']})")
        print(f"POA&M: {results['poam_open_items']} open, "
              f"{results['poam_high_risk_items']} high-risk")
        print(f"Documentation: {results['docs_present']}/{results['docs_total']} key artifacts present")

        if output_path:
            output_path.write_text(
                json.dumps(results, indent=2),
                encoding="utf-8",
            )
            logging.info("Detailed readiness results written to %s", output_path)

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, ValueError, TypeError) as exc:
        logging.exception("ATO readiness assessment failed: %s", exc)
        print(f"[ERROR] ATO readiness assessment failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
