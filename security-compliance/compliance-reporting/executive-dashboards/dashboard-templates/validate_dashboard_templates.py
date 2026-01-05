#!/usr/bin/env python3
"""
validate_dashboard_templates.py

Validate the presence, basic structure, and metadata of compliance dashboard templates
(Grafana, Power BI, Tableau) under the dashboard-templates directory.

This script is designed for:
- CI/CD checks to ensure required templates exist
- Lightweight structural validation (e.g., JSON parse, file extension checks)
- Generating a JSON validation report for downstream tooling

Configuration:
- Defaults work out-of-the-box for the current directory layout
- Optional JSON/YAML config file to override paths and required templates
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # YAML support is optional; handled gracefully


# ----------------------------
# Data models
# ----------------------------

@dataclass
class TemplateCheckResult:
    """Represents validation result for a single dashboard template file."""
    name: str
    path: str
    exists: bool
    is_readable: bool
    type: str
    extra_checks: Dict[str, Any]
    error: Optional[str] = None


@dataclass
class ValidationReport:
    """Aggregated validation report for all templates."""
    root_directory: str
    templates: List[TemplateCheckResult]
    success: bool


# ----------------------------
# Logging setup
# ----------------------------

def configure_logging(verbosity: int) -> None:
    """
    Configure logging based on the requested verbosity level.

    Args:
        verbosity: Integer indicating verbosity level (0=WARNING, 1=INFO, 2+=DEBUG).
    """
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


logger = logging.getLogger("dashboard_template_validator")


# ----------------------------
# Configuration loading
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load configuration from a JSON or YAML file if provided.

    The config can override:
    - root_directory: base directory for dashboard templates
    - required_templates: list of template definitions

    Example config (YAML or JSON):
    root_directory: compliance-reporting/executive-dashboards/dashboard-templates
    required_templates:
      - name: grafana-compliance-dashboard
        filename: grafana-compliance-dashboard.json
        type: grafana
      - name: powerbi-compliance-template
        filename: powerbi-compliance-template.pbix
        type: powerbi
      - name: tableau-compliance-workbook
        filename: tableau-compliance-workbook.twb
        type: tableau

    Args:
        config_path: Optional path to a JSON/YAML config file.

    Returns:
        Parsed configuration dictionary or defaults if no config is provided.
    """
    default_config: Dict[str, Any] = {
        "root_directory": "compliance-reporting/executive-dashboards/dashboard-templates",
        "required_templates": [
            {
                "name": "grafana-compliance-dashboard",
                "filename": "grafana-compliance-dashboard.json",
                "type": "grafana",
            },
            {
                "name": "powerbi-compliance-template",
                "filename": "powerbi-compliance-template.pbix",
                "type": "powerbi",
            },
            {
                "name": "tableau-compliance-workbook",
                "filename": "tableau-compliance-workbook.twb",
                "type": "tableau",
            },
        ],
    }

    if config_path is None:
        logger.debug("No config path provided; using default configuration")
        return default_config

    if not config_path.is_file():
        raise FileNotFoundError(f"Config file not found at: {config_path}")

    logger.debug("Loading config from %s", config_path)

    text = config_path.read_text(encoding="utf-8")

    # Determine parser by extension
    if config_path.suffix.lower() in (".yaml", ".yml"):
        if yaml is None:
            raise RuntimeError(
                "PyYAML is required for YAML config files. "
                "Install with `pip install pyyaml` or use JSON instead."
            )
        config_data = yaml.safe_load(text)
    elif config_path.suffix.lower() == ".json":
        config_data = json.loads(text)
    else:
        raise ValueError(
            f"Unsupported config file extension: {config_path.suffix}. "
            "Use .json or .yaml/.yml."
        )

    # Merge with defaults; config overrides defaults
    merged = {**default_config, **(config_data or {})}

    logger.debug("Loaded configuration: %s", merged)
    return merged


# ----------------------------
# Validation helpers
# ----------------------------

def validate_grafana_template(path: Path) -> Dict[str, Any]:
    """
    Perform lightweight validation for a Grafana JSON dashboard template.

    Checks:
    - File can be parsed as JSON
    - (Optional) Key presence checks (e.g., 'title', 'panels') if available

    Args:
        path: Path to the Grafana JSON file.

    Returns:
        Dict with validation metadata.
    """
    result: Dict[str, Any] = {
        "is_json_valid": False,
        "has_title": False,
        "has_panels": False,
    }

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        result["is_json_valid"] = True
        result["has_title"] = bool(data.get("title"))
        # Grafana dashboards often use 'panels', but this is not guaranteed
        result["has_panels"] = isinstance(data.get("panels"), list)
    except json.JSONDecodeError as exc:
        logger.warning("Failed to parse Grafana template JSON at %s: %s", path, exc)
        result["json_error"] = str(exc)

    return result


def validate_generic_binary(path: Path) -> Dict[str, Any]:
    """
    Lightweight validation for binary templates (e.g., Power BI, Tableau).

    Since file formats are proprietary, we only perform basic checks:
    - File size > 0
    - Extension is as expected (already enforced by config)

    Args:
        path: Path to the binary template file.

    Returns:
        Dict with validation metadata.
    """
    result: Dict[str, Any] = {
        "size_bytes": None,
        "is_non_empty": False,
    }

    try:
        size = path.stat().st_size
        result["size_bytes"] = size
        result["is_non_empty"] = size > 0
    except OSError as exc:
        logger.warning("Failed to stat file %s: %s", path, exc)
        result["stat_error"] = str(exc)

    return result


def validate_template(
    root_directory: Path,
    template_definition: Dict[str, Any],
) -> TemplateCheckResult:
    """
    Validate a single template against its definition.

    Args:
        root_directory: Base directory containing the templates.
        template_definition: Dict containing at least:
            - name: Logical name of the template
            - filename: File name of the template
            - type: 'grafana', 'powerbi', 'tableau', etc.

    Returns:
        TemplateCheckResult with validation details.
    """
    name = template_definition.get("name", "unnamed-template")
    filename = template_definition["filename"]
    template_type = template_definition.get("type", "unknown")

    path = root_directory / filename
    exists = path.is_file()
    is_readable = False
    extra_checks: Dict[str, Any] = {}
    error: Optional[str] = None

    logger.debug("Validating template '%s' at %s", name, path)

    if not exists:
        error = "File not found"
        logger.error("Template %s expected at %s but was not found", name, path)
        return TemplateCheckResult(
            name=name,
            path=str(path),
            exists=False,
            is_readable=False,
            type=template_type,
            extra_checks=extra_checks,
            error=error,
        )

    # Check readability (open for read)
    try:
        with path.open("rb"):
            is_readable = True
    except OSError as exc:
        error = f"Unable to read file: {exc}"
        logger.error("Template %s not readable at %s: %s", name, path, exc)

    # Perform template-type-specific checks if readable
    if is_readable and error is None:
        if template_type.lower() == "grafana":
            extra_checks = validate_grafana_template(path)
        else:
            # Power BI, Tableau, or other binaries
            extra_checks = validate_generic_binary(path)

    return TemplateCheckResult(
        name=name,
        path=str(path),
        exists=exists,
        is_readable=is_readable,
        type=template_type,
        extra_checks=extra_checks,
        error=error,
    )


# ----------------------------
# Core execution
# ----------------------------

def run_validation(
    config: Dict[str, Any],
) -> ValidationReport:
    """
    Execute validation for all configured templates.

    Args:
        config: Configuration dictionary.

    Returns:
        ValidationReport with per-template results and aggregate success flag.
    """
    root_directory = Path(config["root_directory"]).resolve()
    required_templates = config.get("required_templates", [])

    logger.info("Validating dashboard templates under: %s", root_directory)

    if not root_directory.is_dir():
        raise NotADirectoryError(
            f"Root dashboard-templates directory does not exist: {root_directory}"
        )

    results: List[TemplateCheckResult] = []

    for template_def in required_templates:
        result = validate_template(root_directory, template_def)
        results.append(result)

    # Determine success: all templates exist, are readable, and have no error
    success = all(r.exists and r.is_readable and r.error is None for r in results)

    logger.info("Validation completed. Success=%s", success)

    return ValidationReport(
        root_directory=str(root_directory),
        templates=results,
        success=success,
    )


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """
    Parse CLI arguments.

    Args:
        argv: Optional list of arguments (for testing). Defaults to sys.argv.

    Returns:
        Parsed argparse Namespace.
    """
    parser = argparse.ArgumentParser(
        description="Validate compliance dashboard templates (Grafana, Power BI, Tableau)."
    )
    parser.add_argument(
        "--config",
        type=str,
        help="Optional path to JSON or YAML config file.",
    )
    parser.add_argument(
        "--output",
        type=str,
        help="Optional path to write validation report as JSON.",
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
    """
    Main entry point for CLI execution.

    Returns:
        Exit code (0 for success, non-zero for failure).
    """
    args = parse_args(argv)
    configure_logging(args.verbose)

    config_path = Path(args.config).resolve() if args.config else None

    try:
        config = load_config(config_path)
        report = run_validation(config)

        # Serialize report
        report_dict = {
            "root_directory": report.root_directory,
            "success": report.success,
            "templates": [asdict(t) for t in report.templates],
        }
        report_json = json.dumps(report_dict, indent=2)

        if args.output:
            output_path = Path(args.output).resolve()
            output_path.write_text(report_json + "\n", encoding="utf-8")
            logger.info("Validation report written to %s", output_path)
        else:
            # Write to stdout for CI/CD usage
            print(report_json)

        # Non-zero exit code if validation failed
        return 0 if report.success else 1

    except Exception as exc:
        logger.exception("Unhandled error during validation: %s", exc)
        return 2


if __name__ == "__main__":
    sys.exit(main())
