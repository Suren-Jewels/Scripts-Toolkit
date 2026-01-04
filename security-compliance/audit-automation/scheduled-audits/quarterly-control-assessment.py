#!/usr/bin/env python3
"""
quarterly-control-assessment.py

Description:
    Performs a quarterly review of control effectiveness based on a configuration file.
    The script evaluates defined controls, records status, and emits a structured report.

Config concept:
    controls:
      - id: CTRL-001
        name: "MFA enabled for all admins"
        category: "Identity & Access"
        type: "boolean"
        evaluation:
          method: "api"
          target: "entra-id"
          env_token: "ENTRA_API_TOKEN"
      - id: CTRL-002
        name: "Critical systems patched within SLA"
        category: "Patch Management"
        type: "threshold"
        evaluation:
          method: "query"
          source: "vulnerability-scanner"
          max_days: 30

Note:
    Actual integration with external systems is stubbed for safety. Replace stubs with
    concrete implementations as needed.
"""

import argparse
import json
import logging
import os
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # YAML support is optional


@dataclass
class ControlResult:
    control_id: str
    name: str
    category: str
    status: str  # "pass", "fail", "error"
    details: str
    evaluated_at: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Quarterly control effectiveness assessment."
    )
    parser.add_argument(
        "-c",
        "--config",
        required=True,
        help="Path to control assessment configuration (YAML or JSON).",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Path to JSON output report. If omitted, prints to stdout.",
    )
    parser.add_argument(
        "-l",
        "--log-file",
        default="/var/log/audit-automation/quarterly-control-assessment.log",
        help="Path to log file. Default: /var/log/audit-automation/quarterly-control-assessment.log",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity level. Default: INFO",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate evaluation without contacting external systems.",
    )
    return parser.parse_args()


def setup_logging(log_file: str, log_level: str) -> None:
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    formatter = logging.Formatter(
        fmt="%(asctime)s [quarterly-control-assessment] [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    log_path = Path(log_file)
    try:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        fh = logging.FileHandler(log_path, encoding="utf-8")
        fh.setFormatter(formatter)
        logger.addHandler(fh)
    except Exception as exc:  # noqa: BLE001
        logging.warning("Unable to configure file logger at %s: %s", log_file, exc)


def load_config(path: str) -> Dict[str, Any]:
    cfg_path = Path(path)
    if not cfg_path.is_file():
        raise FileNotFoundError(f"Config file not found: {path}")

    text = cfg_path.read_text(encoding="utf-8")
    suffix = cfg_path.suffix.lower()

    if suffix in (".yaml", ".yml"):
        if yaml is None:
            raise RuntimeError("PyYAML is required for YAML configs.")
        return yaml.safe_load(text) or {}
    if suffix == ".json":
        return json.loads(text)

    raise ValueError(f"Unsupported config extension: {suffix}")


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Required environment variable '{name}' is not set.")
    return value


def eval_boolean_control(control: Dict[str, Any], dry_run: bool) -> ControlResult:
    logger = logging.getLogger(__name__)
    cid = control.get("id", "<unknown>")
    name = control.get("name", "<unnamed>")
    category = control.get("category", "Uncategorized")
    evaluation = control.get("evaluation", {})

    logger.info("Evaluating boolean control: %s (%s)", cid, name)

    if dry_run:
        logger.info("[DRY-RUN] Would evaluate boolean control '%s' using %s", cid, evaluation.get("method"))
        status = "pass"
        details = "Dry-run: control assumed to pass."
    else:
        # Placeholder logic; replace with real checks
        method = evaluation.get("method", "none")
        env_token = evaluation.get("env_token")
        if env_token:
            try:
                _ = require_env(env_token)
            except RuntimeError as exc:
                logger.error("Control %s failed: %s", cid, exc)
                return ControlResult(
                    control_id=cid,
                    name=name,
                    category=category,
                    status="error",
                    details=str(exc),
                    evaluated_at=datetime.utcnow().isoformat() + "Z",
                )

        logger.debug("Executing boolean control method: %s", method)
        # Assume control passes by default in this stub
        status = "pass"
        details = f"Control evaluated via method={method}; no issues detected in stub implementation."

    return ControlResult(
        control_id=cid,
        name=name,
        category=category,
        status=status,
        details=details,
        evaluated_at=datetime.utcnow().isoformat() + "Z",
    )


def eval_threshold_control(control: Dict[str, Any], dry_run: bool) -> ControlResult:
    logger = logging.getLogger(__name__)
    cid = control.get("id", "<unknown>")
    name = control.get("name", "<unnamed>")
    category = control.get("category", "Uncategorized")
    evaluation = control.get("evaluation", {})

    logger.info("Evaluating threshold control: %s (%s)", cid, name)

    max_days = evaluation.get("max_days", 30)

    if dry_run:
        logger.info("[DRY-RUN] Would evaluate threshold control '%s' with max_days=%s", cid, max_days)
        status = "pass"
        details = "Dry-run: threshold control assumed to pass."
    else:
        # Placeholder: in real usage, query vulnerability scanner, patch system, etc.
        logger.debug(
            "Querying source '%s' with max_days=%s",
            evaluation.get("source", "unknown-source"),
            max_days,
        )

        # Simulated result: we pretend that actual value is within the threshold
        simulated_current_days = 10
        if simulated_current_days <= max_days:
            status = "pass"
            details = f"Max days since patch = {simulated_current_days} (threshold={max_days})."
        else:
            status = "fail"
            details = f"Max days since patch = {simulated_current_days} exceeds threshold={max_days}."

    return ControlResult(
        control_id=cid,
        name=name,
        category=category,
        status=status,
        details=details,
        evaluated_at=datetime.utcnow().isoformat() + "Z",
    )


def evaluate_controls(config: Dict[str, Any], dry_run: bool) -> List[ControlResult]:
    logger = logging.getLogger(__name__)
    controls = config.get("controls", [])
    if not isinstance(controls, list) or not controls:
        logger.warning("No controls defined in configuration.")
        return []

    results: List[ControlResult] = []
    for control in controls:
        ctype = control.get("type")
        cid = control.get("id", "<unknown>")
        try:
            if ctype == "boolean":
                result = eval_boolean_control(control, dry_run)
            elif ctype == "threshold":
                result = eval_threshold_control(control, dry_run)
            else:
                logger.warning("Control %s has unknown type '%s'; marking as error.", cid, ctype)
                result = ControlResult(
                    control_id=cid,
                    name=control.get("name", "<unnamed>"),
                    category=control.get("category", "Uncategorized"),
                    status="error",
                    details=f"Unknown control type: {ctype}",
                    evaluated_at=datetime.utcnow().isoformat() + "Z",
                )
        except Exception as exc:  # noqa: BLE001
            logger.exception("Error evaluating control %s: %s", cid, exc)
            result = ControlResult(
                control_id=cid,
                name=control.get("name", "<unnamed>"),
                category=control.get("category", "Uncategorized"),
                status="error",
                details=str(exc),
                evaluated_at=datetime.utcnow().isoformat() + "Z",
            )

        results.append(result)

    return results


def write_report(results: List[ControlResult], output_path: Optional[str]) -> None:
    report = {
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "controls": [asdict(r) for r in results],
    }
    report_json = json.dumps(report, indent=2)

    if output_path:
        out_path = Path(output_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(report_json, encoding="utf-8")
        logging.getLogger(__name__).info("Control assessment report written to: %s", output_path)
    else:
        # Print to stdout if no file path provided
        print(report_json)


def main() -> int:
    args = parse_args()
    setup_logging(args.log_file, args.log_level)

    logger = logging.getLogger(__name__)
    logger.info("quarterly-control-assessment started (dry-run=%s)", args.dry_run)

    try:
        config = load_config(args.config)
    except Exception as exc:  # noqa: BLE001
        logger.error("Failed to load configuration: %s", exc)
        return 1

    try:
        results = evaluate_controls(config, args.dry_run)
    except Exception as exc:  # noqa: BLE001
        logger.exception("Unexpected error during control evaluation: %s", exc)
        return 2

    try:
        write_report(results, args.output)
    except Exception as exc:  # noqa: BLE001
        logger.error("Failed to write report: %s", exc)
        return 3

    logger.info("quarterly-control-assessment completed successfully")
    return 0


if __name__ == "__main__":
    sys.exit(main())
