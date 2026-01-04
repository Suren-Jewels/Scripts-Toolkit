#!/usr/bin/env python3
"""
real-time-compliance-monitor.py

Real-time compliance monitoring engine that:
- Subscribes (polls) to an events source (e.g., log file, message queue, API)
- Evaluates events against compliance rules and alert thresholds
- Emits structured findings for downstream systems (SIEM, ticketing, dashboards)

This script is intentionally backend-agnostic:
- Input source can be a file, stdin, or HTTP endpoint (simulated here)
- Rules and thresholds are loaded from a YAML configuration
"""

import argparse
import json
import logging
import sys
import time
from pathlib import Path
from typing import Any, Dict, Iterable, Optional

try:
    import yaml  # type: ignore
except ImportError as exc:
    raise SystemExit(
        "Missing dependency: pyyaml. Install with `pip install pyyaml`."
    ) from exc


# -----------------------------
# Logging setup
# -----------------------------


def setup_logger(verbosity: int) -> logging.Logger:
    """
    Configure and return a module-level logger.

    Parameters
    ----------
    verbosity : int
        Higher value -> more verbose logging, mapped to logging levels.

    Returns
    -------
    logging.Logger
        Configured logger instance.
    """
    logger = logging.getLogger("real_time_compliance_monitor")
    logger.setLevel(logging.DEBUG)

    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)

    if verbosity <= 0:
        log_level = logging.WARNING
    elif verbosity == 1:
        log_level = logging.INFO
    else:
        log_level = logging.DEBUG

    formatter = logging.Formatter(
        "%(asctime)s | %(name)s | %(levelname)s | %(message)s"
    )
    handler.setFormatter(formatter)
    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(log_level)
    return logger


# -----------------------------
# Configuration loading
# -----------------------------


def load_yaml_config(path: Path, logger: logging.Logger) -> Dict[str, Any]:
    """
    Load YAML configuration file and return it as a dictionary.

    Parameters
    ----------
    path : Path
        Path to the YAML configuration file.
    logger : logging.Logger
        Logger for debug and error messages.

    Returns
    -------
    Dict[str, Any]
        Parsed YAML content.

    Raises
    ------
    SystemExit
        If the file cannot be read or parsed.
    """
    if not path.is_file():
        logger.error("Configuration file does not exist: %s", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            config = yaml.safe_load(f) or {}
        logger.debug("Loaded configuration from %s", path)
        return config
    except Exception as exc:
        logger.error("Failed to parse YAML configuration: %s", exc)
        raise SystemExit(1)


# -----------------------------
# Event source abstraction
# -----------------------------


def read_events_from_file(path: Path, logger: logging.Logger) -> Iterable[Dict[str, Any]]:
    """
    Tail-like reader for an event log file.

    This function yields JSON-decoded lines from the file as they appear,
    emulating a streaming event source.

    Parameters
    ----------
    path : Path
        Path to the log file being monitored.
    logger : logging.Logger
        Logger for debug and error messages.

    Yields
    ------
    Dict[str, Any]
        Parsed JSON event objects.
    """
    logger.info("Monitoring file for events: %s", path)

    # Ensure file exists before starting to tail.
    if not path.exists():
        logger.error("Events file does not exist: %s", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            # Move to the end of file for "real-time" behavior
            f.seek(0, 2)
            while True:
                line = f.readline()
                if not line:
                    time.sleep(1.0)
                    continue
                line = line.strip()
                if not line:
                    continue
                try:
                    event = json.loads(line)
                    logger.debug("Received event: %s", event)
                    yield event
                except json.JSONDecodeError as exc:
                    logger.warning("Skipping invalid JSON line: %s | error=%s", line, exc)
    except KeyboardInterrupt:
        logger.info("Interrupted by user, stopping event file monitoring.")
    except Exception as exc:
        logger.error("Error while reading events from file: %s", exc)
        raise SystemExit(1)


# Placeholder for future event source types (HTTP, stdin, etc.)
def get_event_stream(
    source_type: str,
    source_path: Optional[Path],
    logger: logging.Logger,
) -> Iterable[Dict[str, Any]]:
    """
    Return an iterable over event objects for the specified source.

    Parameters
    ----------
    source_type : str
        Type of event source. Currently supports: "file".
    source_path : Optional[Path]
        Path to the source file (for source_type="file").
    logger : logging.Logger
        Logger instance.

    Returns
    -------
    Iterable[Dict[str, Any]]
        Iterable of JSON-compatible events.

    Raises
    ------
    SystemExit
        If source_type is unsupported or parameters are invalid.
    """
    if source_type == "file":
        if not source_path:
            logger.error("source_path is required when source_type is 'file'.")
            raise SystemExit(1)
        return read_events_from_file(source_path, logger)

    logger.error("Unsupported source_type: %s", source_type)
    raise SystemExit(1)


# -----------------------------
# Compliance evaluation engine
# -----------------------------


def evaluate_event_against_rules(
    event: Dict[str, Any],
    rules: Dict[str, Any],
    thresholds: Dict[str, Any],
    logger: logging.Logger,
) -> Dict[str, Any]:
    """
    Evaluate a single event against compliance rules and thresholds.

    This function is intentionally simple and should be replaced or extended
    with your organization's domain-specific logic.

    Parameters
    ----------
    event : Dict[str, Any]
        Event payload to evaluate. Expected to contain fields like "type", "severity".
    rules : Dict[str, Any]
        Generic rules configuration loaded from YAML.
    thresholds : Dict[str, Any]
        Alert threshold rules loaded from YAML.
    logger : logging.Logger
        Logger instance for debug details.

    Returns
    -------
    Dict[str, Any]
        Finding record containing:
        - event: original event
        - compliant: bool
        - severity: str
        - rule_id: str or None
        - details: str
    """
    event_type = event.get("type", "unknown")
    event_severity = event.get("severity", "low")

    # Resolve rule by event type; fallback to default rule.
    type_rules = rules.get("event_type_rules", {})
    rule = type_rules.get(event_type, rules.get("default_rule", {}))

    allowed_severity = rule.get("max_allowed_severity", "medium")

    severity_order = ["low", "medium", "high", "critical"]
    try:
        event_sev_index = severity_order.index(event_severity)
        allowed_index = severity_order.index(allowed_severity)
    except ValueError:
        logger.debug(
            "Unknown severity encountered. event_severity=%s allowed_severity=%s",
            event_severity,
            allowed_severity,
        )
        # Treat unknown severities as non-compliant.
        event_sev_index = len(severity_order)
        allowed_index = len(severity_order) - 1

    compliant = event_sev_index <= allowed_index

    # Determine if we should escalate based on thresholds.
    threshold_rule = thresholds.get("severity_thresholds", {})
    threshold_limit = threshold_rule.get(event_severity, {}).get("max_per_minute", None)

    finding = {
        "event": event,
        "compliant": compliant,
        "severity": event_severity,
        "rule_id": rule.get("id", None),
        "details": "",
        "threshold_limit": threshold_limit,
    }

    if not compliant:
        finding["details"] = (
            f"Event severity '{event_severity}' exceeds allowed '{allowed_severity}' "
            f"for type '{event_type}'."
        )
    else:
        finding["details"] = "Event is compliant with configured rules."

    logger.debug("Evaluated event. finding=%s", finding)
    return finding


def emit_finding(finding: Dict[str, Any], output: str, logger: logging.Logger) -> None:
    """
    Emit a compliance finding to the configured output channel.

    For simplicity, this implementation:
    - Writes JSON to stdout or
    - Appends JSON to a file

    Parameters
    ----------
    finding : Dict[str, Any]
        Evaluation result to emit.
    output : str
        Either "stdout" or a filesystem path.
    logger : logging.Logger
        Logger instance.

    Raises
    ------
    SystemExit
        If writing to the file fails.
    """
    serialized = json.dumps(finding, separators=(",", ":"), sort_keys=True)

    if output == "stdout":
        print(serialized)
        return

    # Treat output as file path
    output_path = Path(output)
    try:
        with output_path.open("a", encoding="utf-8") as f:
            f.write(serialized + "\n")
        logger.debug("Appended finding to %s", output_path)
    except Exception as exc:
        logger.error("Failed to write finding to file: %s", exc)
        raise SystemExit(1)


# -----------------------------
# Main orchestration
# -----------------------------


def parse_args(argv: Optional[Iterable[str]] = None) -> argparse.Namespace:
    """
    Parse command-line arguments.

    Parameters
    ----------
    argv : Optional[Iterable[str]]
        Optional iterable of arguments for testing.

    Returns
    -------
    argparse.Namespace
        Parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Real-time compliance monitoring engine."
    )

    parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to YAML configuration file (rules, backends, etc.).",
    )

    parser.add_argument(
        "--thresholds",
        required=True,
        type=Path,
        help="Path to alert thresholds YAML (e.g., alert-thresholds.yaml).",
    )

    parser.add_argument(
        "--source-type",
        choices=["file"],
        default="file",
        help="Event source type. Currently supports: file.",
    )

    parser.add_argument(
        "--source-path",
        type=Path,
        required=True,
        help="Path to event source (e.g., log file) when source-type=file.",
    )

    parser.add_argument(
        "--output",
        default="stdout",
        help="Output channel: 'stdout' or a file path for JSON findings.",
    )

    parser.add_argument(
        "--poll-interval",
        type=float,
        default=1.0,
        help="Polling interval in seconds for supported sources.",
    )

    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (-v, -vv).",
    )

    return parser.parse_args(list(argv) if argv is not None else None)


def main() -> None:
    """
    Entry point for the real-time compliance monitor.

    This function wires together configuration loading, event streaming,
    rule evaluation, and finding emission.
    """
    args = parse_args()
    logger = setup_logger(args.verbose)

    logger.info("Starting real-time compliance monitor.")
    logger.debug("Arguments: %s", args)

    rules_config = load_yaml_config(args.config, logger)
    thresholds_config = load_yaml_config(args.thresholds, logger)

    event_stream = get_event_stream(args.source_type, args.source_path, logger)

    # The poll interval is used in the file reader internals in this version.
    # It remains a parameter here to avoid breaking compatibility if additional
    # source types are implemented.
    _ = args.poll_interval

    try:
        for event in event_stream:
            finding = evaluate_event_against_rules(
                event=event,
                rules=rules_config,
                thresholds=thresholds_config,
                logger=logger,
            )
            emit_finding(finding, args.output, logger)
    except KeyboardInterrupt:
        logger.info("Received keyboard interrupt, shutting down.")
    except Exception as exc:
        logger.exception("Fatal error in monitoring loop: %s", exc)
        raise SystemExit(1)


if __name__ == "__main__":
    main()
