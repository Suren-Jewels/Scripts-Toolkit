#!/usr/bin/env python3
"""
remediation-plan-generator.py

Auto-generates remediation plans for audit findings.

Features:
- Reads findings JSON (with risk scores if available)
- Uses YAML templates to suggest remediation actions and SLAs
- Generates a structured remediation plan JSON or Markdown
- Configurable via CLI and optional config file
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional

import yaml  # Requires PyYAML; keep as a standard, non-credential dependency


# -------------------------
# Data models
# -------------------------


@dataclass
class RemediationTask:
    """
    Represents a single remediation task.
    """
    id: str
    finding_id: str
    title: str
    description: str
    owner_role: str
    target_date: str
    status: str = "PLANNED"
    notes: Optional[str] = None
    template_id: Optional[str] = None


# -------------------------
# Template loading and mapping
# -------------------------


def load_templates(path: Path) -> Dict[str, Any]:
    """
    Load remediation templates from YAML file.

    Expected structure (high level):
    - id: template-1
      match:
        severity: HIGH
        category: "Access Control"
      sla_days: 30
      owner_role: "Security Engineering"
      remediation_steps:
        - ...
    """
    if not path.exists():
        logging.error("Template file '%s' does not exist.", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or []
    except yaml.YAMLError as exc:
        logging.error("Unable to parse YAML template file: %s", exc)
        raise SystemExit(1)

    if not isinstance(data, list):
        logging.error("Template file must contain a list of templates.")
        raise SystemExit(1)

    logging.debug("Loaded %d remediation templates from '%s'.", len(data), path)
    return {"templates": data}


def load_findings(path: Path) -> List[Dict[str, Any]]:
    """
    Load findings JSON (any structure, but should include at least: id, title, severity).
    """
    if not path.exists():
        logging.error("Findings file '%s' does not exist.", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Unable to parse findings JSON: %s", exc)
        raise SystemExit(1)

    if not isinstance(data, list):
        logging.error("Findings file is expected to contain a list of objects.")
        raise SystemExit(1)

    logging.debug("Loaded %d findings for remediation plan generation.", len(data))
    return data


def match_template_for_finding(
    finding: Dict[str, Any],
    templates: List[Dict[str, Any]],
) -> Optional[Dict[str, Any]]:
    """
    Select the most appropriate template for a given finding based on
    severity, category, and optionally risk level.
    """
    severity = str(finding.get("severity", "")).upper()
    category = str(finding.get("category", "")).upper()
    risk_level = str(finding.get("risk_level", "")).upper()

    best_match: Optional[Dict[str, Any]] = None
    best_score = -1

    for template in templates:
        match = template.get("match", {})
        score = 0

        # Exact matches increase the score
        tmpl_severity = str(match.get("severity", "")).upper()
        tmpl_category = str(match.get("category", "")).upper()
        tmpl_risk = str(match.get("risk_level", "")).upper()

        if tmpl_severity and tmpl_severity == severity:
            score += 2
        if tmpl_category and tmpl_category == category:
            score += 2
        if tmpl_risk and tmpl_risk == risk_level:
            score += 1

        # Generic templates (with fewer constraints) can still apply
        if score == 0 and not match:
            score = 1

        if score > best_score:
            best_score = score
            best_match = template

    if best_match:
        logging.debug(
            "Matched template '%s' to finding '%s' with score %d.",
            best_match.get("id"),
            finding.get("id"),
            best_score,
        )
    else:
        logging.debug("No matching template found for finding '%s'.", finding.get("id"))

    return best_match


def calculate_target_date(sla_days: int) -> str:
    """
    Calculate target completion date based on current date and SLA days.
    """
    target = datetime.utcnow() + timedelta(days=sla_days)
    return target.date().isoformat()


def build_remediation_tasks_for_finding(
    finding: Dict[str, Any],
    template: Optional[Dict[str, Any]],
    default_sla_days: int,
) -> List[RemediationTask]:
    """
    Create remediation tasks for a finding using a matched template.

    If no template is available, generate a generic remediation task to avoid gaps.
    """
    tasks: List[RemediationTask] = []
    finding_id = str(finding.get("id"))
    title = str(finding.get("title", "Untitled Finding"))

    if template is None:
        logging.warning(
            "No remediation template found for finding '%s'; generating generic task.",
            finding_id,
        )
        target_date = calculate_target_date(default_sla_days)
        tasks.append(
            RemediationTask(
                id=f"{finding_id}-GENERIC-1",
                finding_id=finding_id,
                title=f"Generic remediation for: {title}",
                description="Review finding and define specific remediation actions.",
                owner_role="Risk Owner",
                target_date=target_date,
                notes="No specific template matched; generic remediation created.",
                template_id=None,
            )
        )
        return tasks

    tmpl_id = str(template.get("id"))
    sla_days = int(template.get("sla_days", default_sla_days))
    owner_role = str(template.get("owner_role", "Risk Owner"))
    steps = template.get("remediation_steps", [])

    if not isinstance(steps, list) or not steps:
        # If template has no steps, create a single high-level task
        logging.warning(
            "Template '%s' has no remediation_steps; generating single umbrella task.",
            tmpl_id,
        )
        target_date = calculate_target_date(sla_days)
        tasks.append(
            RemediationTask(
                id=f"{finding_id}-{tmpl_id}-1",
                finding_id=finding_id,
                title=f"Remediate finding: {title}",
                description="Implement agreed remediation for the finding.",
                owner_role=owner_role,
                target_date=target_date,
                template_id=tmpl_id,
            )
        )
        return tasks

    for idx, step in enumerate(steps, start=1):
        description = str(step)
        task_id = f"{finding_id}-{tmpl_id}-{idx}"
        target_date = calculate_target_date(sla_days)
        tasks.append(
            RemediationTask(
                id=task_id,
                finding_id=finding_id,
                title=f"{title} - Step {idx}",
                description=description,
                owner_role=owner_role,
                target_date=target_date,
                template_id=tmpl_id,
            )
        )

    return tasks


# -------------------------
# Output formatting
# -------------------------


def output_json(tasks: List[RemediationTask], output_path: Path) -> None:
    """
    Write remediation tasks as JSON.
    """
    data = [asdict(t) for t in tasks]
    try:
        with output_path.open("w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, sort_keys=True)
        logging.info("Wrote %d remediation tasks to JSON '%s'.", len(tasks), output_path)
    except OSError as exc:
        logging.error("Unable to write JSON remediation plan: %s", exc)
        raise SystemExit(1)


def output_markdown(tasks: List[RemediationTask], output_path: Path) -> None:
    """
    Write remediation tasks in Markdown format for human consumption.
    """
    # Group tasks by finding for more readable markdown
    by_finding: Dict[str, List[RemediationTask]] = {}
    for task in tasks:
        by_finding.setdefault(task.finding_id, []).append(task)

    lines: List[str] = []
    lines.append("# Remediation Plan")
    lines.append("")
    lines.append(f"_Generated at: {datetime.utcnow().isoformat()}Z_")
    lines.append("")

    for finding_id, f_tasks in sorted(by_finding.items()):
        lines.append(f"## Finding {finding_id}")
        lines.append("")
        for task in sorted(f_tasks, key=lambda t: t.id):
            lines.append(f"### Task {task.id}")
            lines.append("")
            lines.append(f"- **Title:** {task.title}")
            lines.append(f"- **Owner role:** {task.owner_role}")
            lines.append(f"- **Target date:** {task.target_date}")
            lines.append(f"- **Status:** {task.status}")
            if task.template_id:
                lines.append(f"- **Template:** `{task.template_id}`")
            if task.notes:
                lines.append(f"- **Notes:** {task.notes}")
            lines.append("")
            lines.append("**Description:**")
            lines.append("")
            lines.append(task.description)
            lines.append("")
        lines.append("---")
        lines.append("")

    try:
        with output_path.open("w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        logging.info("Wrote remediation plan markdown to '%s'.", output_path)
    except OSError as exc:
        logging.error("Unable to write Markdown remediation plan: %s", exc)
        raise SystemExit(1)


# -------------------------
# Config and CLI
# -------------------------


def load_config(path: Optional[Path]) -> Dict[str, Any]:
    """
    Load optional configuration file (JSON).

    Example:
    {
      "default_sla_days": 60,
      "default_output_format": "json"
    }
    """
    if path is None:
        logging.debug("No config file specified; using defaults.")
        return {}

    if not path.exists():
        logging.error("Config file '%s' does not exist.", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            cfg = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Invalid JSON in config file: %s", exc)
        raise SystemExit(1)

    logging.debug("Loaded generator configuration from '%s'.", path)
    return cfg


def build_parser() -> argparse.ArgumentParser:
    """
    Construct CLI parser.
    """
    parser = argparse.ArgumentParser(
        description="Generate remediation plans from findings and templates.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--config",
        type=Path,
        help="Optional JSON config file for generator defaults."
    )

    parser.add_argument(
        "--findings",
        required=True,
        type=Path,
        help="Path to findings JSON file."
    )

    parser.add_argument(
        "--templates",
        required=True,
        type=Path,
        help="Path to YAML remediation templates file."
    )

    parser.add_argument(
        "--output",
        required=True,
        type=Path,
        help="Output path for remediation plan (JSON or Markdown)."
    )

    parser.add_argument(
        "--format",
        choices=["json", "md"],
        help="Output format (overrides config default_output_format)."
    )

    parser.add_argument(
        "--default-sla-days",
        type=int,
        help="Default SLA days when template does not specify sla_days."
    )

    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging verbosity level."
    )

    return parser


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

    cfg = load_config(args.config)
    findings = load_findings(args.findings)
    tmpl_data = load_templates(args.templates)
    templates = tmpl_data["templates"]

    default_sla_days = args.default_sla_days or cfg.get("default_sla_days", 60)
    output_format = args.format or cfg.get("default_output_format", "json")

    all_tasks: List[RemediationTask] = []
    for finding in findings:
        template = match_template_for_finding(finding, templates)
        tasks = build_remediation_tasks_for_finding(finding, template, default_sla_days)
        all_tasks.extend(tasks)

    if output_format == "json":
        output_json(all_tasks, args.output)
    elif output_format == "md":
        output_markdown(all_tasks, args.output)
    else:
        logging.error("Unsupported output format: '%s'.", output_format)
        raise SystemExit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logging.warning("Interrupted by user.")
        sys.exit(130)
