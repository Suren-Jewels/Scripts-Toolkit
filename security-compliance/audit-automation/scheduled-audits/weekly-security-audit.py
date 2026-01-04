#!/usr/bin/env python3
"""
weekly-security-audit.py

Description:
    Executes a weekly security audit using a configuration file.
    Intended to be scheduled (e.g., cron, systemd timers, CI pipelines).

Features:
    - Argument-based configuration (config path, log level, dry-run)
    - YAML/JSON config support (auto-detected by extension)
    - Structured logging for debugging and auditability
    - No hardcoded credentials; expects environment variables or external secret stores
"""

import argparse
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # YAML support is optional


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description="Weekly security audit runner."
    )
    parser.add_argument(
        "-c",
        "--config",
        required=True,
        help="Path to audit configuration file (YAML or JSON).",
    )
    parser.add_argument(
        "-l",
        "--log-file",
        default="/var/log/audit-automation/weekly-security-audit.log",
        help="Path to log file. Default: /var/log/audit-automation/weekly-security-audit.log",
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
        help="Print what would be executed without performing actions.",
    )
    return parser.parse_args()


def setup_logging(log_file: str, log_level: str) -> None:
    """
    Configure logging to both console and file.

    Logging failures should not break the main logic, so file handlers are set up
    defensively.
    """
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    formatter = logging.Formatter(
        fmt="%(asctime)s [weekly-security-audit] [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    # Console handler
    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    # File handler (best-effort)
    log_path = Path(log_file)
    try:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        fh = logging.FileHandler(log_path, encoding="utf-8")
        fh.setFormatter(formatter)
        logger.addHandler(fh)
    except Exception as exc:  # noqa: BLE001
        logging.warning("Unable to configure file logger at %s: %s", log_file, exc)


def load_config(config_path: str) -> Dict[str, Any]:
    """Load configuration from YAML or JSON based on file extension."""
    path = Path(config_path)
    if not path.is_file():
        raise FileNotFoundError(f"Config file does not exist: {config_path}")

    suffix = path.suffix.lower()
    with path.open("r", encoding="utf-8") as f:
        content = f.read()

    if suffix in (".yaml", ".yml"):
        if yaml is None:
            raise RuntimeError("PyYAML is not installed but YAML config was provided.")
        return yaml.safe_load(content) or {}
    if suffix == ".json":
        return json.loads(content)

    raise ValueError(f"Unsupported config format '{suffix}'. Use .yaml, .yml, or .json.")


def get_required_env(var_name: str) -> str:
    """
    Fetch a required environment variable.

    This is a safe way to obtain secrets without hardcoding them in the script or config.
    """
    value = os.getenv(var_name)
    if not value:
        raise RuntimeError(f"Required environment variable '{var_name}' is not set.")
    return value


def run_port_scan(targets: List[str], dry_run: bool) -> bool:
    """
    Example security check: port scan against defined targets.

    In production, this might integrate with tools like nmap or custom scanners.
    Here, we just log intent and simulate success for demonstration.
    """
    logger = logging.getLogger(__name__)
    logger.info("Starting port scan on %d target(s)", len(targets))

    for target in targets:
        if dry_run:
            logger.info("[DRY-RUN] Would scan target: %s", target)
        else:
            # Placeholder: insert real port scan logic or subprocess call here.
            logger.debug("Scanning target: %s", target)
            # Example: subprocess.run(["nmap", "-sV", target], check=False)

    logger.info("Port scan step completed")
    return True


def run_config_drift_check(config: Dict[str, Any], dry_run: bool) -> bool:
    """
    Example security check: configuration drift detection.

    This would typically compare actual system configs against a known-good baseline.
    """
    logger = logging.getLogger(__name__)
    baseline_id = config.get("baseline_id", "default-baseline")
    logger.info("Starting configuration drift check (baseline_id=%s)", baseline_id)

    if dry_run:
        logger.info("[DRY-RUN] Would compute drift for baseline: %s", baseline_id)
        return True

    # Placeholder logic: real implementation would query CMDB, pull configs, etc.
    logger.debug("Computing configuration drift for baseline_id=%s", baseline_id)
    # Simulated result
    drift_detected = False

    if drift_detected:
        logger.error("Configuration drift detected for baseline_id=%s", baseline_id)
        return False

    logger.info("No configuration drift detected for baseline_id=%s", baseline_id)
    return True


def run_identity_checks(config: Dict[str, Any], dry_run: bool) -> bool:
    """
    Example security check: identity and access anomalies.

    Typically integrates with identity provider APIs, SIEM queries, or log aggregators.
    """
    logger = logging.getLogger(__name__)
    provider = config.get("provider", "generic-idp")
    logger.info("Starting identity checks against provider: %s", provider)

    env_var_name = config.get("api_token_env")
    if env_var_name:
        try:
            _ = get_required_env(env_var_name)
        except RuntimeError as exc:
            logger.error("Identity check aborted: %s", exc)
            return False

    if dry_run:
        logger.info("[DRY-RUN] Would query identity provider: %s", provider)
        return True

    # Placeholder for real identity checks
    logger.debug("Querying identity provider: %s", provider)
    # Example: detect dormant accounts, excessive permissions, etc.

    logger.info("Identity checks completed successfully for provider: %s", provider)
    return True


def run_audit(config: Dict[str, Any], dry_run: bool) -> bool:
    """
    Orchestrate the weekly security audit based on config.

    Expected config structure (example):
        checks:
          - type: port-scan
            targets: ["192.168.1.10", "example.com"]
          - type: config-drift
            baseline_id: "prod-linux-baseline"
          - type: identity
            provider: "okta"
            api_token_env: "OKTA_API_TOKEN"
    """
    logger = logging.getLogger(__name__)
    checks = config.get("checks", [])
    if not isinstance(checks, list) or not checks:
        logger.warning("No checks defined in configuration.")
        return True

    logger.info("Initiating weekly security audit with %d configured check(s)", len(checks))
    failures = 0

    for idx, check in enumerate(checks, start=1):
        ctype = check.get("type")
        logger.info("Running check %d: type=%s", idx, ctype)

        try:
            if ctype == "port-scan":
                targets = check.get("targets", [])
                if not isinstance(targets, list) or not targets:
                    logger.warning("Check %d: port-scan has no targets; skipping", idx)
                    continue
                if not run_port_scan(targets, dry_run):
                    failures += 1

            elif ctype == "config-drift":
                if not run_config_drift_check(check, dry_run):
                    failures += 1

            elif ctype == "identity":
                if not run_identity_checks(check, dry_run):
                    failures += 1

            else:
                logger.warning("Check %d: Unknown type '%s'; skipping", idx, ctype)

        except Exception as exc:  # noqa: BLE001
            logger.exception("Check %d (type=%s) failed with unexpected error: %s", idx, ctype, exc)
            failures += 1

    if failures > 0:
        logger.error("Weekly security audit completed with %d failing check(s)", failures)
        return False

    logger.info("Weekly security audit completed successfully with all checks passing")
    return True


def main() -> int:
    """Entry point."""
    args = parse_args()
    setup_logging(args.log_file, args.log_level)

    logger = logging.getLogger(__name__)
    logger.info("weekly-security-audit started (dry-run=%s)", args.dry_run)

    try:
        config = load_config(args.config)
    except Exception as exc:  # noqa: BLE001
        logger.error("Failed to load configuration: %s", exc)
        return 1

    try:
        success = run_audit(config, args.dry_run)
    except Exception as exc:  # noqa: BLE001
        logger.exception("Unexpected error during audit execution: %s", exc)
        return 2

    if not success:
        return 3

    logger.info("weekly-security-audit finished successfully")
    return 0


if __name__ == "__main__":
    sys.exit(main())
