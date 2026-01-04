#!/usr/bin/env python3
"""
risk-scorer.py

Calculates risk scores for audit findings.

Features:
- Reads findings from JSON file (compatible with finding-tracker.py)
- Calculates risk score using configurable weights
- Outputs updated findings with risk scores
- Configurable via JSON config file and CLI arguments
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict, field
from pathlib import Path
from typing import List, Dict, Any, Optional


# -------------------------
# Data models
# -------------------------


@dataclass
class Finding:
    """
    Simplified finding model for risk scoring. Extra fields are kept
    in `metadata` to avoid data loss.
    """
    id: str
    title: str
    severity: str
    # Optional domain-specific attributes that influence risk
    impact: Optional[int] = None
    likelihood: Optional[int] = None
    # Computed values
    risk_score: Optional[float] = None
    risk_level: Optional[str] = None
    # Everything else
    metadata: Dict[str, Any] = field(default_factory=dict)


# -------------------------
# Risk scoring logic
# -------------------------


DEFAULT_SEVERITY_WEIGHTS: Dict[str, int] = {
    # These are defaults; can be overridden via config file
    "LOW": 1,
    "MEDIUM": 2,
    "HIGH": 3,
    "CRITICAL": 4,
}


def normalize_severity(severity: str) -> str:
    """
    Normalizes severity strings for consistent key lookup.
    """
    return severity.strip().upper()


def map_dict_to_finding(data: Dict[str, Any]) -> Finding:
    """
    Map raw dictionary data from storage into a Finding instance,
    preserving unknown fields in metadata.
    """
    known_fields = {"id", "title", "severity", "impact", "likelihood", "risk_score", "risk_level"}
    core: Dict[str, Any] = {}
    metadata: Dict[str, Any] = {}

    for key, value in data.items():
        if key in known_fields:
            core[key] = value
        else:
            metadata[key] = value

    return Finding(
        id=core.get("id", ""),
        title=core.get("title", ""),
        severity=core.get("severity", "MEDIUM"),
        impact=core.get("impact"),
        likelihood=core.get("likelihood"),
        risk_score=core.get("risk_score"),
        risk_level=core.get("risk_level"),
        metadata=metadata,
    )


def calculate_risk_score(
    finding: Finding,
    severity_weights: Dict[str, int],
    impact_weight: float,
    likelihood_weight: float,
) -> Finding:
    """
    Compute risk score and level for a given finding.

    Basic formula:
      base = severity_weight(severity)
      impact_component = (impact or base) * impact_weight
      likelihood_component = (likelihood or base) * likelihood_weight
      risk_score = base + impact_component + likelihood_component

    The risk level is derived from the resulting score thresholds,
    which are also configurable.
    """
    severity_key = normalize_severity(finding.severity)
    base = severity_weights.get(severity_key, severity_weights.get("MEDIUM", 2))

    impact_value = finding.impact if finding.impact is not None else base
    likelihood_value = finding.likelihood if finding.likelihood is not None else base

    risk_score = float(
        base + (impact_value * impact_weight) + (likelihood_value * likelihood_weight)
    )
    finding.risk_score = round(risk_score, 2)

    logging.debug(
        "Finding '%s' severity='%s', impact=%s, likelihood=%s -> score=%.2f",
        finding.id,
        finding.severity,
        impact_value,
        likelihood_value,
        finding.risk_score,
    )

    return finding


def assign_risk_level(
    finding: Finding,
    level_thresholds: Dict[str, float],
) -> Finding:
    """
    Assign risk level based on score thresholds.

    Example thresholds:
      {
        "LOW": 0,
        "MEDIUM": 5,
        "HIGH": 10,
        "CRITICAL": 15
      }

    The highest matching level threshold less than or equal to the score is selected.
    """
    score = finding.risk_score or 0.0
    selected_level = "LOW"
    # Sort thresholds by score ascending
    sorted_levels = sorted(level_thresholds.items(), key=lambda kv: kv[1])
    for level, threshold in sorted_levels:
        if score >= threshold:
            selected_level = level

    finding.risk_level = selected_level
    logging.debug(
        "Finding '%s' assigned risk level '%s' for score %.2f",
        finding.id,
        finding.risk_level,
        score,
    )
    return finding


# -------------------------
# I/O helpers
# -------------------------


def load_findings(path: Path) -> List[Finding]:
    """
    Load findings from JSON file.
    """
    if not path.exists():
        logging.error("Findings file '%s' does not exist.", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            raw_list = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Unable to parse findings JSON: %s", exc)
        raise SystemExit(1)

    findings = [map_dict_to_finding(item) for item in raw_list]
    logging.debug("Loaded %d findings from '%s'.", len(findings), path)
    return findings


def save_findings(path: Path, findings: List[Finding]) -> None:
    """
    Persist findings with risk scores to JSON file.
    """
    serialized: List[Dict[str, Any]] = []
    for finding in findings:
        base = asdict(finding)
        # Merge metadata back into top-level structure
        metadata = base.pop("metadata", {}) or {}
        merged = {**metadata, **base}
        serialized.append(merged)

    try:
        with path.open("w", encoding="utf-8") as f:
            json.dump(serialized, f, indent=2, sort_keys=True)
        logging.info("Saved %d scored findings to '%s'.", len(findings), path)
    except OSError as exc:
        logging.error("Unable to write findings JSON: %s", exc)
        raise SystemExit(1)


def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load optional config file for risk scoring logic.

    Expected structure (example):
    {
      "severity_weights": {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4},
      "impact_weight": 1.5,
      "likelihood_weight": 1.0,
      "risk_levels": {
        "LOW": 0,
        "MEDIUM": 5,
        "HIGH": 10,
        "CRITICAL": 15
      }
    }
    """
    if config_path is None:
        logging.debug("No config file specified; using built-in defaults.")
        return {}

    if not config_path.exists():
        logging.error("Config file '%s' does not exist.", config_path)
        raise SystemExit(1)

    try:
        with config_path.open("r", encoding="utf-8") as f:
            cfg = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in config file: %s", exc)
        raise SystemExit(1)

    logging.debug("Loaded risk configuration from '%s'.", config_path)
    return cfg


# -------------------------
# Argument parsing
# -------------------------


def build_parser() -> argparse.ArgumentParser:
    """
    Build CLI parser.
    """
    parser = argparse.ArgumentParser(
        description="Calculate risk scores for audit findings.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--config",
        type=Path,
        help="Optional path to risk configuration JSON file."
    )

    parser.add_argument(
        "--input",
        required=True,
        type=Path,
        help="Path to input findings JSON file."
    )

    parser.add_argument(
        "--output",
        type=Path,
        help="Path to output scored findings JSON file. If omitted, input file is overwritten."
    )

    parser.add_argument(
        "--impact-weight",
        type=float,
        help="Override impact weight (multiplier)."
    )

    parser.add_argument(
        "--likelihood-weight",
        type=float,
        help="Override likelihood weight (multiplier)."
    )

    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging verbosity level."
    )

    return parser


# -------------------------
# Main orchestration
# -------------------------


def main(argv: Optional[List[str]] = None) -> None:
    """
    Entry point.
    """
    parser = build_parser()
    args = parser.parse_args(argv)

    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format="%(asctime)s | %(levelname)s | %(message)s",
    )

    config = load_config(args.config)

    severity_weights = {
        **DEFAULT_SEVERITY_WEIGHTS,
        **config.get("severity_weights", {}),
    }

    impact_weight = args.impact_weight if args.impact_weight is not None else config.get(
        "impact_weight", 1.0
    )
    likelihood_weight = (
        args.likelihood_weight
        if args.likelihood_weight is not None
        else config.get("likelihood_weight", 1.0)
    )

    level_thresholds: Dict[str, float] = config.get(
        "risk_levels",
        {
            "LOW": 0.0,
            "MEDIUM": 5.0,
            "HIGH": 10.0,
            "CRITICAL": 15.0,
        },
    )

    logging.info(
        "Using impact_weight=%.2f, likelihood_weight=%.2f",
        impact_weight,
        likelihood_weight,
    )

    findings = load_findings(args.input)
    scored_findings: List[Finding] = []

    for finding in findings:
        finding = calculate_risk_score(
            finding, severity_weights, impact_weight, likelihood_weight
        )
        finding = assign_risk_level(finding, level_thresholds)
        scored_findings.append(finding)

    output_path = args.output or args.input
    save_findings(output_path, scored_findings)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logging.warning("Interrupted by user.")
        sys.exit(130)
