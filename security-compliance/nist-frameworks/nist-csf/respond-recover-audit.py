#!/usr/bin/env python3
"""
Respond/Recover Capability Audit for NIST CSF

Evaluates organization capabilities for:
- Respond (e.g., incident response runbooks, on-call coverage)
- Recover (e.g., backup/restoration, DR exercises)

Uses a JSON configuration file describing expected artifacts and readiness
scores, then emits a structured summary.

Example config:
{
  "respond": {
    "runbook_present": true,
    "oncall_coverage_hours": 24,
    "tested_in_last_days": 90
  },
  "recover": {
    "backup_frequency_hours": 24,
    "last_restore_test_days": 120,
    "rpo_hours": 24,
    "rto_hours": 48
  }
}
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, Any


def configure_logging(verbosity: int) -> None:
    """
    Configure logging level based on verbosity.
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


def load_json(path: Path) -> Dict[str, Any]:
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
        return data or {}
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in file %s: %s", path, exc)
        raise


def evaluate_respond(respond_cfg: Dict[str, Any]) -> Dict[str, Any]:
    """
    Evaluate Respond capabilities based on config.
    Returns a dict with computed metrics and a basic qualitative rating.
    """
    runbook_present = bool(respond_cfg.get("runbook_present", False))
    oncall_hours = int(respond_cfg.get("oncall_coverage_hours", 0))
    last_test_days = int(respond_cfg.get("tested_in_last_days", 9999))

    score = 0
    if runbook_present:
        score += 1
    if oncall_hours >= 16:
        score += 1
    if last_test_days <= 180:
        score += 1

    if score == 3:
        rating = "STRONG"
    elif score == 2:
        rating = "ADEQUATE"
    else:
        rating = "WEAK"

    logging.debug(
        "Respond evaluation: runbook=%s, oncall_hours=%d, last_test_days=%d, score=%d, rating=%s",
        runbook_present,
        oncall_hours,
        last_test_days,
        score,
        rating,
    )

    return {
        "score": score,
        "rating": rating,
        "runbook_present": runbook_present,
        "oncall_coverage_hours": oncall_hours,
        "tested_in_last_days": last_test_days,
    }


def evaluate_recover(recover_cfg: Dict[str, Any]) -> Dict[str, Any]:
    """
    Evaluate Recover capabilities based on config.
    Returns a dict with computed metrics and a basic qualitative rating.
    """
    backup_frequency = int(recover_cfg.get("backup_frequency_hours", 0))
    last_restore_test = int(recover_cfg.get("last_restore_test_days", 9999))
    rpo_hours = int(recover_cfg.get("rpo_hours", 0))
    rto_hours = int(recover_cfg.get("rto_hours", 0))

    score = 0
    if 0 < backup_frequency <= 24:
        score += 1
    if last_restore_test <= 365:
        score += 1
    if 0 < rpo_hours <= 24:
        score += 1
    if 0 < rto_hours <= 72:
        score += 1

    if score >= 3:
        rating = "STRONG"
    elif score == 2:
        rating = "ADEQUATE"
    else:
        rating = "WEAK"

    logging.debug(
        "Recover evaluation: backup_freq=%d, last_restore_test=%d, rpo=%d, rto=%d, score=%d, rating=%s",
        backup_frequency,
        last_restore_test,
        rpo_hours,
        rto_hours,
        score,
        rating,
    )

    return {
        "score": score,
        "rating": rating,
        "backup_frequency_hours": backup_frequency,
        "last_restore_test_days": last_restore_test,
        "rpo_hours": rpo_hours,
        "rto_hours": rto_hours,
    }


def parse_arguments() -> argparse.Namespace:
    """
    Parse CLI arguments.
    """
    parser = argparse.ArgumentParser(
        description="Audit Respond/Recover capabilities for NIST CSF."
    )
    parser.add_argument(
        "--config",
        required=True,
        help="Path to JSON configuration describing Respond/Recover capabilities.",
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
    Main entry point for the Respond/Recover audit.
    """
    args = parse_arguments()
    configure_logging(args.verbose)

    config_path = Path(args.config)
    output_path = Path(args.output) if args.output else None

    try:
        config = load_json(config_path)

        respond_cfg = config.get("respond", {})
        recover_cfg = config.get("recover", {})

        respond_results = evaluate_respond(respond_cfg)
        recover_results = evaluate_recover(recover_cfg)

        print("[RESULT] Respond/Recover Capability Audit")
        print(f"Respond rating: {respond_results['rating']} (score: {respond_results['score']})")
        print(f"Recover rating: {recover_results['rating']} (score: {recover_results['score']})")

        if output_path:
            detailed = {
                "respond": respond_results,
                "recover": recover_results,
            }
            output_path.write_text(
                json.dumps(detailed, indent=2),
                encoding="utf-8",
            )
            logging.info("Detailed audit results written to %s", output_path)

        sys.exit(0)

    except (FileNotFoundError, json.JSONDecodeError, ValueError, TypeError) as exc:
        logging.exception("Respond/Recover audit failed: %s", exc)
        print(f"[ERROR] Respond/Recover audit failed: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
