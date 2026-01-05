#!/usr/bin/env python3
"""
risk-heatmap-generator.py

Generate an executive-ready risk heatmap data structure from a list of risks.

The script:
- Ingests a CSV or JSON file with risk records
- Normalises likelihood and impact levels into a grid
- Outputs a JSON heatmap matrix consumable by dashboards

Expected input schema:
- risk_id: Unique risk identifier
- description: Human-readable description
- likelihood: One of {1,2,3,4,5} or {low, medium, high, very_high, critical}
- impact: Same scheme as likelihood
- status: Optional (e.g., "open", "mitigated", "accepted")

Configuration:
- Likert scale mapping from labels to numeric (1–5)
- Output grid size and bucket labels
"""

import argparse
import json
import logging
import sys
from collections import defaultdict
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union


logger = logging.getLogger("risk_heatmap_generator")


# ----------------------------
# Data models
# ----------------------------

@dataclass
class HeatmapCell:
    """Represents a single cell in the likelihood/impact grid."""
    likelihood: str
    impact: str
    risk_count: int
    open_risks: int
    mitigated_risks: int
    accepted_risks: int


@dataclass
class HeatmapResult:
    """Top-level representation of the heatmap."""
    likelihood_axis: List[str]
    impact_axis: List[str]
    cells: List[HeatmapCell]


# ----------------------------
# Configuration
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load JSON configuration if provided.

    Example config:
    {
      "levels": ["low", "medium", "high", "very_high", "critical"],
      "status_categories": ["open", "mitigated", "accepted"]
    }
    """
    default_config: Dict[str, Any] = {
        "levels": ["low", "medium", "high", "very_high", "critical"],
        "status_categories": ["open", "mitigated", "accepted"],
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
    """Load risk records from CSV or JSON."""
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

    # CSV path
    import csv

    rows: List[Record] = []
    with input_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows


# ----------------------------
# Heatmap generation
# ----------------------------

def normalise_level(value: Union[str, int, float], levels: List[str]) -> Optional[str]:
    """
    Map raw likelihood/impact value to a canonical level label.

    Supports:
    - Numeric input (1–len(levels)) -> index into levels
    - String input (case-insensitive) -> must match one of levels

    Returns:
        Normalised level or None if invalid.
    """
    if isinstance(value, (int, float)):
        index = int(value) - 1
        if 0 <= index < len(levels):
            return levels[index]
        return None

    text = str(value).strip().lower()
    for level in levels:
        if text == level.lower():
            return level

    # Allow synonyms for typical scales
    synonyms = {
        "low": "low",
        "medium": "medium",
        "med": "medium",
        "high": "high",
        "very high": "very_high",
        "very_high": "very_high",
        "critical": "critical",
    }
    if text in synonyms and synonyms[text] in levels:
        return synonyms[text]

    return None


def normalise_status(value: Any, valid_statuses: List[str]) -> str:
    """
    Normalise the risk status into one of the configured categories.

    Defaults to "open" if not recognised.
    """
    text = str(value or "open").strip().lower()
    for status in valid_statuses:
        if text == status.lower():
            return status
    return "open"


def build_heatmap(
    records: List[Record],
    levels: List[str],
    status_categories: List[str],
) -> HeatmapResult:
    """
    Build a heatmap grid from risk records.

    Args:
        records: Raw risk records.
        levels: Ordered list of level labels.
        status_categories: Allowed status categories.

    Returns:
        HeatmapResult with structured cell data.
    """
    # Nested dict: (likelihood, impact) -> dict of counts
    cell_counts: Dict[Tuple[str, str], Dict[str, int]] = defaultdict(
        lambda: {"total": 0, "open": 0, "mitigated": 0, "accepted": 0}
    )

    for row in records:
        raw_likelihood = row.get("likelihood")
        raw_impact = row.get("impact")

        likelihood = normalise_level(raw_likelihood, levels)
        impact = normalise_level(raw_impact, levels)

        if likelihood is None or impact is None:
            logger.warning(
                "Skipping risk with invalid likelihood/impact: likelihood=%s impact=%s row=%s",
                raw_likelihood,
                raw_impact,
                row,
            )
            continue

        status = normalise_status(row.get("status"), status_categories)
        counts = cell_counts[(likelihood, impact)]
        counts["total"] += 1
        counts[status] = counts.get(status, 0) + 1

    cells: List[HeatmapCell] = []
    for likelihood in levels:
        for impact in levels:
            counts = cell_counts.get((likelihood, impact), {})
            cell = HeatmapCell(
                likelihood=likelihood,
                impact=impact,
                risk_count=counts.get("total", 0),
                open_risks=counts.get("open", 0),
                mitigated_risks=counts.get("mitigated", 0),
                accepted_risks=counts.get("accepted", 0),
            )
            cells.append(cell)

    return HeatmapResult(
        likelihood_axis=levels,
        impact_axis=levels,
        cells=cells,
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
        description="Generate an executive risk heatmap matrix from risk records."
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
        help="Path to write the heatmap JSON.",
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
        levels = list(config.get("levels", []))
        status_categories = list(config.get("status_categories", []))

        if not levels:
            raise ValueError("Configuration 'levels' must not be empty")

        records = load_records(input_path)
        heatmap = build_heatmap(records, levels, status_categories)

        serialised = {
            "likelihood_axis": heatmap.likelihood_axis,
            "impact_axis": heatmap.impact_axis,
            "cells": [asdict(c) for c in heatmap.cells],
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(serialised, indent=2) + "\n", encoding="utf-8")
        logger.info("Risk heatmap written to %s", output_path)
        return 0

    except Exception as exc:
        logger.exception("Failed to generate risk heatmap: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
