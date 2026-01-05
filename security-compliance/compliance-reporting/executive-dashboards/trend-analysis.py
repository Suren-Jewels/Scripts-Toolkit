#!/usr/bin/env python3
"""
trend-analysis.py

Produce time-series trend data for compliance metrics, suitable for executive dashboards.

The script:
- Reads time-stamped compliance scores from CSV or JSON
- Aggregates by a specified time bucket (day/week/month)
- Outputs a JSON time series for charting (line charts, area charts, etc.)

Expected input schema:
- timestamp: ISO 8601 datetime or date string
- domain: Optional domain/category
- score: Numeric score in [0,1] or [0,100] as configured

Configuration:
- score_scale: 1 or 100
- bucket: "day", "week", or "month"
- optional domain filter
"""

import argparse
import json
import logging
import sys
from collections import defaultdict
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union


logger = logging.getLogger("trend_analysis")


# ----------------------------
# Data models
# ----------------------------

@dataclass
class TrendPoint:
    """Represents a single point in the time series."""
    period_start: str  # ISO 8601 date string
    average_score: float
    min_score: float
    max_score: float
    count: int


@dataclass
class TrendSeries:
    """Time series for a single domain or overall."""
    label: str
    points: List[TrendPoint]


@dataclass
class TrendResult:
    """Top-level trend result."""
    bucket: str
    score_scale: int
    series: List[TrendSeries]


# ----------------------------
# Configuration
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load JSON configuration if provided.

    Example config:
    {
      "score_scale": 1,
      "bucket": "month",
      "domain_filter": null
    }
    """
    default_config: Dict[str, Any] = {
        "score_scale": 1,
        "bucket": "month",
        "domain_filter": None,
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
    """Load records from CSV or JSON."""
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
# Trend computation
# ----------------------------

def normalise_score(raw_score: Union[str, float, int], scale: int) -> float:
    """Normalise a score to [0,1] based on scale."""
    try:
        score_num = float(raw_score)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"Invalid score value: {raw_score}") from exc

    if scale == 1:
        return max(0.0, min(1.0, score_num))
    if scale == 100:
        return max(0.0, min(1.0, score_num / 100.0))

    raise ValueError(f"Unsupported score_scale: {scale}")


def parse_timestamp(value: Any) -> datetime:
    """
    Parse a timestamp into a datetime.

    Supports ISO 8601 and 'YYYY-MM-DD'.
    """
    text = str(value).strip()
    for fmt in ("%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d"):
        try:
            return datetime.strptime(text, fmt)
        except ValueError:
            continue
    try:
        return datetime.fromisoformat(text)
    except ValueError as exc:
        raise ValueError(f"Unsupported timestamp format: {text}") from exc


def bucket_key(dt: datetime, bucket: str) -> str:
    """
    Get a bucket key (period start date) for the given datetime.

    - day: YYYY-MM-DD
    - week: ISO week start (Monday)
    - month: YYYY-MM-01
    """
    if bucket == "day":
        return dt.strftime("%Y-%m-%d")
    if bucket == "week":
        # ISO week: we normalise to Monday of that week
        weekday = dt.weekday()
        monday = dt.replace(hour=0, minute=0, second=0, microsecond=0)  # type: ignore[assignment]
        # mypy note aside; we do not enforce type-checker here
        from datetime import timedelta
        monday = monday - timedelta(days=weekday)
        return monday.strftime("%Y-%m-%d")
    if bucket == "month":
        first = dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        return first.strftime("%Y-%m-%d")
    raise ValueError(f"Unsupported bucket: {bucket}")


def compute_trends(
    records: List[Record],
    score_scale: int,
    bucket: str,
    domain_filter: Optional[str],
) -> TrendResult:
    """
    Compute time-series trends from raw records.

    Args:
        records: Input records.
        score_scale: 1 or 100.
        bucket: 'day', 'week', or 'month'.
        domain_filter: Optional specific domain to filter.

    Returns:
        TrendResult with per-domain and overall series.
    """
    # per (label, period) -> list of scores
    scores_by_label_period: Dict[Tuple[str, str], List[float]] = defaultdict(list)

    for row in records:
        try:
            timestamp_raw = row.get("timestamp")
            if timestamp_raw is None:
                logger.warning("Skipping record with no timestamp: %s", row)
                continue
            dt = parse_timestamp(timestamp_raw)
            period = bucket_key(dt, bucket)

            domain = str(row.get("domain") or "Overall")
            score = normalise_score(row.get("score"), score_scale)
        except ValueError as exc:
            logger.warning("Skipping invalid record: %s (error=%s)", row, exc)
            continue

        if domain_filter and domain != domain_filter:
            # Include only matching domain when filter is specified
            continue

        # Domain-specific series
        scores_by_label_period[(domain, period)].append(score)

        # Overall series if no domain_filter
        if not domain_filter:
            scores_by_label_period[("Overall", period)].append(score)

    if not scores_by_label_period:
        raise RuntimeError("No valid time-series data found after processing input")

    # Build series
    series_map: Dict[str, Dict[str, List[float]]] = defaultdict(lambda: defaultdict(list))
    for (label, period), scores in scores_by_label_period.items():
        series_map[label][period].extend(scores)

    series_list: List[TrendSeries] = []
    for label, period_scores in series_map.items():
        points: List[TrendPoint] = []
        for period in sorted(period_scores.keys()):
            scores = period_scores[period]
            point = TrendPoint(
                period_start=period,
                average_score=sum(scores) / len(scores),
                min_score=min(scores),
                max_score=max(scores),
                count=len(scores),
            )
            points.append(point)
        series_list.append(TrendSeries(label=label, points=points))

    return TrendResult(
        bucket=bucket,
        score_scale=score_scale,
        series=series_list,
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
        description="Generate compliance trend time-series data for executive dashboards."
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
        help="Path to write trend JSON.",
    )
    parser.add_argument(
        "--config",
        "-c",
        help="Optional path to JSON configuration file.",
    )
    parser.add_argument(
        "--bucket",
        choices=["day", "week", "month"],
        help="Override bucket from config (day|week|month).",
    )
    parser.add_argument(
        "--domain",
        help="Optional domain filter; if set, only that domain is included.",
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
        bucket = args.bucket or str(config.get("bucket", "month"))
        domain_filter = args.domain or config.get("domain_filter")

        records = load_records(input_path)
        result = compute_trends(records, score_scale, bucket, domain_filter)

        serialised = {
            "bucket": result.bucket,
            "score_scale": result.score_scale,
            "series": [
                {
                    "label": s.label,
                    "points": [asdict(p) for p in s.points],
                }
                for s in result.series
            ],
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(serialised, indent=2) + "\n", encoding="utf-8")
        logger.info("Trend time series written to %s", output_path)
        return 0

    except Exception as exc:
        logger.exception("Failed to generate trend analysis: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
