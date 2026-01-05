#!/usr/bin/env python3
"""
kpi-tracker.py

Track and summarise compliance-related KPIs for executive dashboards.

The script:
- Ingests KPI definitions and current values from CSV or JSON
- Evaluates each KPI against targets and thresholds
- Outputs a JSON structure with status indicators (e.g., GREEN/YELLOW/RED)

Expected input schema:
- kpi_id: Unique KPI identifier
- name: Human-friendly KPI name
- category: Optional grouping (e.g., "Identity", "Network")
- current_value: Numeric
- target_value: Numeric
- direction: "up_is_good" or "down_is_good"

Configuration:
- Warning and critical deviation thresholds (e.g., 10% and 20%)
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Union


logger = logging.getLogger("kpi_tracker")


# ----------------------------
# Data models
# ----------------------------

@dataclass
class KpiStatus:
    """Evaluated status for a single KPI."""
    kpi_id: str
    name: str
    category: str
    current_value: float
    target_value: float
    direction: str
    deviation_percent: float
    status: str  # GREEN, YELLOW, RED


@dataclass
class KpiSummary:
    """Top-level KPI summary."""
    warning_threshold_percent: float
    critical_threshold_percent: float
    kpis: List[KpiStatus]


# ----------------------------
# Configuration
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load JSON configuration if provided.

    Example config:
    {
      "warning_threshold_percent": 10.0,
      "critical_threshold_percent": 20.0
    }
    """
    default_config: Dict[str, Any] = {
        "warning_threshold_percent": 10.0,
        "critical_threshold_percent": 20.0,
    }

    if config_path is None:
        return default_config

    if not config_path.is_file():
        raise FileNotFoundError(f"Config file not found: {config_path}")

    try:
        config_data = json.loads(config_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ValueError(f"Config file is not valid JSON: {exc}") from exc

    if not isinstance(config_data, dict):
        raise ValueError("Config file must contain a JSON object")

    merged = {**default_config, **config_data}
    logger.debug("Loaded configuration: %s", merged)
    return merged


# ----------------------------
# Input loading
# ----------------------------

Record = Dict[str, Any]


def detect_format(path: Path) -> str:
    """Infer file format from extension."""
    ext = path.suffix.lower()
    if ext == ".csv":
        return "csv"
    if ext == ".json":
        return "json"
    raise ValueError(f"Unsupported input file format: {ext}")


def load_records(input_path: Path) -> List[Record]:
    """Load KPI records from CSV or JSON."""
    if not input_path.is_file():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    file_format = detect_format(input_path)
    logger.info("Loading input data from %s (format=%s)", input_path, file_format)

    if file_format == "json":
        data = json.loads(input_path.read_text(encoding="utf-8"))
        if isinstance(data, dict):
            data = data.get("items") or data.get("records") or []
        if not isinstance(data, list):
            raise ValueError("JSON input must be a list or an object containing 'items'/'records'")
        return [r for r in data if isinstance(r, dict)]

    import csv

    rows: List[Record] = []
    with input_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows


# ----------------------------
# KPI evaluation
# ----------------------------

def to_float(value: Any, field_name: str) -> float:
    """Convert a value to float with validation."""
    try:
        return float(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"Invalid numeric value for {field_name}: {value}") from exc


def compute_deviation_percent(
    current: float,
    target: float,
    direction: str,
) -> float:
    """
    Compute percentage deviation from target.

    For direction == "up_is_good":
      deviation = ((target - current) / target) * 100 (positive = underperforming)

    For direction == "down_is_good":
      deviation = ((current - target) / target) * 100 (positive = over target, bad)

    If target is zero, deviation is treated as 0.0 to avoid division by zero.
    """
    if target == 0:
        return 0.0

    if direction == "up_is_good":
        return ((target - current) / target) * 100.0
    if direction == "down_is_good":
        return ((current - target) / target) * 100.0

    raise ValueError(f"Unsupported direction: {direction}")


def classify_status(
    deviation_percent: float,
    warning_threshold: float,
    critical_threshold: float,
) -> str:
    """
    Classify KPI status based on deviation.

    - |deviation| <= warning_threshold -> GREEN
    - warning_threshold < |deviation| <= critical_threshold -> YELLOW
    - |deviation| > critical_threshold -> RED
    """
    deviation_magnitude = abs(deviation_percent)

    if deviation_magnitude <= warning_threshold:
        return "GREEN"
    if deviation_magnitude <= critical_threshold:
        return "YELLOW"
    return "RED"


def evaluate_kpis(
    records: List[Record],
    warning_threshold: float,
    critical_threshold: float,
) -> KpiSummary:
    """
    Evaluate KPIs from raw records.

    Args:
        records: Input KPI records.
        warning_threshold: Warning deviation percent.
        critical_threshold: Critical deviation percent.

    Returns:
        KpiSummary with per-KPI status.
    """
    statuses: List[KpiStatus] = []

    for row in records:
        try:
            kpi_id = str(row.get("kpi_id") or "").strip()
            name = str(row.get("name") or "").strip()
            if not kpi_id or not name:
                logger.warning("Skipping KPI with missing id or name: %s", row)
                continue

            category = str(row.get("category") or "Uncategorised")
            direction = str(row.get("direction") or "up_is_good").strip()

            current_value = to_float(row.get("current_value"), "current_value")
            target_value = to_float(row.get("target_value"), "target_value")

            deviation = compute_deviation_percent(current_value, target_value, direction)
            status = classify_status(deviation, warning_threshold, critical_threshold)

            statuses.append(
                KpiStatus(
                    kpi_id=kpi_id,
                    name=name,
                    category=category,
                    current_value=current_value,
                    target_value=target_value,
                    direction=direction,
                    deviation_percent=deviation,
                    status=status,
                )
            )
        except ValueError as exc:
            logger.warning("Skipping KPI due to invalid data: %s (error=%s)", row, exc)
            continue

    if not statuses:
        raise RuntimeError("No valid KPI records found in input data")

    return KpiSummary(
        warning_threshold_percent=warning_threshold,
        critical_threshold_percent=critical_threshold,
        kpis=statuses,
    )


# ----------------------------
# CLI handling
# ----------------------------

def configure_logging(verbosity: int) -> None:
    """Set up logging based on verbosity."""
    if verbosity <= 0:
        level = logging.WARNING
    elif verbosity == 1:
        level = logging.INFO
    else:
        level = logging.DEBUG

    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    )


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description="Evaluate compliance KPIs and generate an executive summary."
    )
    parser.add_argument(
        "--input",
        "-i",
        required=True,
        help="Path to KPI input data (CSV or JSON).",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        help="Path to write KPI summary JSON.",
    )
    parser.add_argument(
        "--config",
        "-c",
        help="Optional path to JSON configuration file.",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="count",
        default=0,
        help="Increase verbosity (use -v, -vv).",
    )
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """Main entry point."""
    args = parse_args(argv)
    configure_logging(args.verbose)

    input_path = Path(args.input).resolve()
    output_path = Path(args.output).resolve()
    config_path = Path(args.config).resolve() if args.config else None

    try:
        config = load_config(config_path)
        warning_threshold = float(config.get("warning_threshold_percent", 10.0))
        critical_threshold = float(config.get("critical_threshold_percent", 20.0))

        records = load_records(input_path)
        summary = evaluate_kpis(records, warning_threshold, critical_threshold)

        serialised = {
            "warning_threshold_percent": summary.warning_threshold_percent,
            "critical_threshold_percent": summary.critical_threshold_percent,
            "kpis": [asdict(k) for k in summary.kpis],
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(serialised, indent=2) + "\n", encoding="utf-8")
        logger.info("KPI summary written to %s", output_path)
        return 0

    except Exception as exc:
        logger.exception("Failed to generate KPI summary: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
