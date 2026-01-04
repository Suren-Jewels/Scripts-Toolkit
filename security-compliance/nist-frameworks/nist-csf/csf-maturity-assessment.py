#!/usr/bin/env python3
"""
CSF Maturity Assessment

Computes maturity scores for NIST Cybersecurity Framework (CSF) implementation using:
- A CSF implementation description (JSON/YAML)
- A CSF tier definition file (csf-implementation-tiers.yaml)

The script:
- Calculates per-function scores (Identify, Protect, Detect, Respond, Recover)
- Determines an overall implementation tier recommendation
- Outputs a summary suitable for reporting and dashboards
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, Any, Tuple

import yaml  # type: ignore[import-untyped]


def configure_logging(verbosity: int) -> None:
    """
    Configure logging verbosity.
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


def load_yaml(path: Path) -> Dict[str, Any]:
    """
    Load a YAML file and return it as a dictionary.
    """
    if not path.exists():
        logging.error("YAML file not found: %s", path)
        raise FileNotFoundError(f"YAML file not found: {path}")
    try:
        with path.open("r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        logging.debug("Loaded YAML file: %s", path)
        return data or {}
    except yaml.YAMLError as exc:
        logging.error("Invalid YAML in file %s: %s", path, exc)
        raise


def load_json(path: Path) -> Dict[str, Any]:
    """
    Load a JSON file and return it as a dictionary.
    """
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


def calculate_function_score(values: Dict[str, Any]) -> float:
    """
    Calculate an average maturity score for a single CSF function.

    Expects values like:
    {
      "ID.AM": 3,
      "ID.BE": 2
    }

    Returns a float between 0-4 (assuming 0-4 scale).
    """
    scores = []
    for subcategory, score in values.items():
        try:
            numeric_score = float(score)
            scores.append(numeric_score)
        except (TypeError, ValueError):
            logging.warning("Non-numeric score for %s; skipping.", subcategory)
    if not scores:
        return 0.0
    return sum(scores) / len(scores)


def assign_tier(overall_score: float, tiers: Dict[str, Any]) -> Tuple[str, str]:
    """
    Assign an implementation tier based on overall score and tier definitions.

    Tier YAML example:
    tiers:
      1:
        name: "Tier 1 - Partial"
        min_score: 0.0
        max_score: 1.0
      2:
        name: "Tier 2 - Risk Informed"
        min_score: 1.0
        max_score: 2.5
    """
    tier_definitions = tiers.get("tiers", {})
    selected_id = None
    selected_name = "Unknown Tier"

    for tier_id, definition in tier_definitions.items():
        min_score = float(definition.get("min_score", 0.0))
        max_score = float(definition.get("max_score", 4.0))
        if min_score <= overall_score <= max_score:
            selected_id = str(tier_id)
            selected_name = str(definition.get("name", f"Tier {tier_id}"))
            break

    if selected_id is None:
        logging.warning(
            "No matching tier found for score %.2f; using default.",
            overall_score,
        )
        return "N/A", "Tier not defined for score range"

    logging.debug("Assigned tier %s (%s) for score %.2f", selected_id, selected_name, overall_score)
    return selected_id, selected_name


def parse_arguments() -> argparse.Namespace:
    """
    Parse CLI arguments.
    """
    parser = argparse.ArgumentParser(
        description="NIST CSF maturity assessment tool."
    )
    parser.add_argument(
        "--implementation",
        required=True,
        help="Path to CSF implementation JSON file.",
    )
    parser.add_argument(
        "--tiers",
        required=True,
        help="Path to csf-implementation-tiers.yaml file.",
    )
    parser.add_argument(
        "--output",
        required=False,
        help="Optional output JSON file for detailed results.",
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
    Main entry point for the CSF maturity assessment script.
    """
    args = parse_arguments()
    configure_logging(args.verbose)

    implementation_path = Path(args.implementation)
    tiers_path = Path(args.tiers)
    output_path = Path(args.output) if args.output else None

    try:
        implementation = load_json(implementation_path)
        tiers = load_yaml(tiers_path)

        # Expect structure:
        # {
        #   "Identify": { "ID.AM": 3, "ID.BE": 2 },
        #   "Protect": { ... },
        #   ...
        # }
        function_scores = {}
        for function_name, subcategories in implementation.items():
            if not isinstance(subcategories, dict):
                logging.warning("Function %s has non-dict value; skipping.", function_name)
                continue
            score = calculate_function_score(subcategories)
            function_scores[function_name] = score

        if not function_scores:
            raise ValueError("No valid CSF function scores found in implementation file.")

        overall_score = sum(function_scores.values()) / len(function_scores)
        tier_id, tier_name = assign_tier(overall_score, tiers)

        print("[RESULT] NIST CSF Maturity Assessment")
        for fn, score in sorted(function_scores.items()):
            print(f" - {fn}: {score:.2f}")
        print(f"\nOverall Score: {overall_score:.2f}")
        print(f"Recommended Tier: {tier_id} ({tier_name})")

        # Optionally write detailed JSON output
        if output_path:
            detailed = {
                "function_scores": function_scores,
                "overall_score": overall_score,
                "tier_id": tier_id,
                "tier_name": tier_name,
            }
            output_path.write_text(
                json.dumps(detailed, indent=2),
                encoding="utf-8",
            )
            logging.info("Detailed results written to %s", output_path)

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, yaml.YAMLError, ValueError) as exc:
        logging.exception("Maturity assessment failed: %s", exc)
        print(f"[ERROR] Maturity assessment failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
