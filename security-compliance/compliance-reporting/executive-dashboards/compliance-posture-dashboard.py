#!/usr/bin/env python3
"""
compliance-posture-dashboard.py

Compute and export an executive-level compliance posture summary from a flat data source.

The script:
- Reads compliance findings or control scores from CSV or JSON
- Aggregates overall posture by domain and control
- Outputs a JSON summary that can be consumed by dashboards (Grafana/Power BI/Tableau/etc.)

Expected input schema (CSV or JSON list of objects):
- domain: High-level area (e.g., "Identity", "Network", "Data Protection")
- control_id: Unique control identifier
- score: Numeric score in the range [0,1] (or [0,100] if configured)
- severity: Optional severity (e.g., "low", "medium", "high", "critical")

Configuration:
- CLI flags (input path, output path, score-scale)
- Optional JSON config file to override defaults

No credentials are handled here; upstream data retrieval should be done separately.
"""

import argparse
import json
import logging
import sys
from collections import defaultdict
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union


logger = logging.getLogger("compliance_posture_dashboard")


# ----------------------------
# Data models
# ----------------------------

@dataclass
class DomainPosture:
    """Aggregated compliance posture for a single domain."""
    domain: str
    average_score: float
    min_score: float
    max_score: float
    control_count: int
    failing_controls: int


@dataclass
class PostureSummary:
    """Top-level compliance posture summary."""
    overall_average_score: float
    domains: List[DomainPosture]
    total_controls: int
    total_failing_controls: int
    score_scale: int


# ----------------------------
# Configuration loading
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load JSON configuration if a path is provided.

    Example config:
    {
      "score_scale": 1,
      "failing_threshold": 0.7
    }

    Args:
        config_path: Path to JSON config file.

    Returns:
        Merged configuration dict.
    """
    default_config: Dict[str, Any] = {
        "score_scale": 1,          # 1 for [0,1], 100 for [0,100]
        "failing_threshold": 0.7,  # Below this is considered failing
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
    """
    Load compliance records from CSV or JSON.

    Args:
        input_path: Path to the input file.

    Returns:
        List of row dictionaries.
    """
    if not input_path.is_file():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    file_format = detect_format(input_path)
    logger.info("Loading input data from %s (format=%s)", input_path, file_format)

    if file_format == "json":
        data = json.loads(input_path.read_text(encoding="utf-8"))
        if isinstance(data, dict):
            # Allow a top-level "items" or similar
            data = data.get("items") or data.get("records") or []
        if not isinstance(data, list):
            raise ValueError("JSON input must be a list or an object containing 'items'/'records'")
        return [r for r in data if isinstance(r, dict)]

    # CSV path
    import csv

    rows: List[Record] = []
    with input_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows


# ----------------------------
# Aggregation logic
# ----------------------------

def normalise_score(raw_score: Union[str, float, int], scale: int) -> float:
    """
    Normalise a score to the [0,1] range based on configured scale.

    Args:
        raw_score: Original score value (string or numeric).
        scale: 1 for [0,1], 100 for [0,100].

    Returns:
        Normalised score in [0,1].

    Raises:
        ValueError if the score cannot be parsed.
    """
    try:
        score_num = float(raw_score)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"Invalid score value: {raw_score}") from exc

    if scale == 1:
        return max(0.0, min(1.0, score_num))
    if scale == 100:
        return max(0.0, min(1.0, score_num / 100.0))

    raise ValueError(f"Unsupported score_scale: {scale}")


def aggregate_posture(
    records: List[Record],
    score_scale: int,
    failing_threshold: float,
) -> PostureSummary:
    """
    Aggregate records into domain and overall compliance posture.

    Args:
        records: List of input records.
        score_scale: 1 or 100.
        failing_threshold: Scores below this are considered failing.

    Returns:
        PostureSummary with domain-level and overall metrics.
    """
    by_domain: Dict[str, List[float]] = defaultdict(list)
    failing_by_domain: Dict[str, int] = defaultdict(int)

    all_scores: List[float] = []
    total_controls = 0
    total_failing_controls = 0

    for row in records:
        try:
            domain = str(row.get("domain") or "UNSPECIFIED")
            score_raw = row.get("score")
            score = normalise_score(score_raw, score_scale)
        except ValueError as exc:
            logger.warning("Skipping record with invalid score: %s (error=%s)", row, exc)
            continue

        by_domain[domain].append(score)
        all_scores.append(score)
        total_controls += 1

        if score < failing_threshold:
            failing_by_domain[domain] += 1
            total_failing_controls += 1

    if not all_scores:
        raise RuntimeError("No valid scores found in input data")

    domains_summary: List[DomainPosture] = []
    for domain, scores in by_domain.items():
        domain_posture = DomainPosture(
            domain=domain,
            average_score=sum(scores) / len(scores),
            min_score=min(scores),
            max_score=max(scores),
            control_count=len(scores),
            failing_controls=failing_by_domain.get(domain, 0),
        )
        domains_summary.append(domain_posture)

    overall_average = sum(all_scores) / len(all_scores)

    return PostureSummary(
        overall_average_score=overall_average,
        domains=domains_summary,
        total_controls=total_controls,
        total_failing_controls=total_failing_controls,
        score_scale=score_scale,
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
        description="Generate an executive compliance posture summary from raw control findings."
    )
    parser.add_argument(
        "--input",
        "-i",
        required=True,
        help="Path to input data (CSV or JSON).",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        help="Path to write the posture summary JSON.",
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
        score_scale = int(config.get("score_scale", 1))
        failing_threshold = float(config.get("failing_threshold", 0.7))

        records = load_records(input_path)
        summary = aggregate_posture(records, score_scale, failing_threshold)

        serialised = {
            "overall_average_score": summary.overall_average_score,
            "score_scale": summary.score_scale,
            "total_controls": summary.total_controls,
            "total_failing_controls": summary.total_failing_controls,
            "domains": [asdict(d) for d in summary.domains],
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(serialised, indent=2) + "\n", encoding="utf-8")
        logger.info("Compliance posture summary written to %s", output_path)
        return 0

    except Exception as exc:
        logger.exception("Failed to generate compliance posture summary: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
