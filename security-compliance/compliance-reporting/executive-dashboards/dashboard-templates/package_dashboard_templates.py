#!/usr/bin/env python3
"""
package_dashboard_templates.py

Package compliance dashboard templates into a versioned archive suitable for
distribution (e.g., attaching to a release, copying to an artifacts store).

This script focuses purely on packaging; any remote upload should be performed by
separate tooling (CI/CD, artifact repositories, etc.) to avoid hardcoding
credentials.

Features:
- Packages selected or all templates into a ZIP
- Optional version label (e.g., derived from CI build or Git tag)
- Configurable root directory and explicit template list via config file
- Robust logging and error handling
"""

import argparse
import logging
import sys
import zipfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

import json

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # YAML support is optional


# ----------------------------
# Data models
# ----------------------------

@dataclass
class PackagePlan:
    """Represents what will be included in the packaged archive."""
    root_directory: str
    template_files: List[str]
    version_label: str
    archive_path: str


# ----------------------------
# Logging setup
# ----------------------------

def configure_logging(verbosity: int) -> None:
    """
    Configure logging based on verbosity level.

    Args:
        verbosity: 0=WARNING, 1=INFO, 2+=DEBUG.
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


logger = logging.getLogger("dashboard_template_packager")


# ----------------------------
# Configuration loading
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load a JSON or YAML config file if provided.

    Example config:
    root_directory: compliance-reporting/executive-dashboards/dashboard-templates
    templates:
      - grafana-compliance-dashboard.json
      - powerbi-compliance-template.pbix
      - tableau-compliance-workbook.twb

    If `templates` is omitted or empty, all known dashboard files in root_directory
    will be packaged.

    Args:
        config_path: Optional path to JSON/YAML config.

    Returns:
        Configuration dictionary.
    """
    default_config: Dict[str, Any] = {
        "root_directory": "compliance-reporting/executive-dashboards/dashboard-templates",
        "templates": None,
    }

    if config_path is None:
        logger.debug("No config file provided; using default configuration")
        return default_config

    if not config_path.is_file():
        raise FileNotFoundError(f"Config file not found at: {config_path}")

    logger.debug("Loading config from %s", config_path)
    text = config_path.read_text(encoding="utf-8")

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

    merged = {**default_config, **(config_data or {})}
    logger.debug("Loaded configuration: %s", merged)
    return merged


# ----------------------------
# Packaging logic
# ----------------------------

def discover_templates(root_directory: Path) -> List[Path]:
    """
    Discover dashboard template files in the root_directory by known extensions.

    Args:
        root_directory: Directory to scan.

    Returns:
        List of Path objects for discovered template files.
    """
    if not root_directory.is_dir():
        raise NotADirectoryError(
            f"Dashboard templates directory does not exist: {root_directory}"
        )

    logger.info("Discovering dashboard templates under %s", root_directory)

    templates: List[Path] = []
    for path in root_directory.iterdir():
        if not path.is_file():
            continue
        if path.suffix.lower() not in {".json", ".pbix", ".twb", ".twbx"}:
            logger.debug("Skipping non-dashboard file: %s", path)
            continue
        templates.append(path)

    logger.info("Discovered %d dashboard template(s)", len(templates))
    return templates


def build_package_plan(
    config: Dict[str, Any],
    version_label: Optional[str],
    output_dir: Path,
) -> PackagePlan:
    """
    Build a PackagePlan describing which templates will be archived.

    Args:
        config: Configuration dictionary.
        version_label: Optional version label supplied via CLI.
        output_dir: Directory to place the resulting archive.

    Returns:
        PackagePlan instance.
    """
    root_directory = Path(config["root_directory"]).resolve()
    if not root_directory.is_dir():
        raise NotADirectoryError(
            f"Dashboard templates directory does not exist: {root_directory}"
        )

    configured_templates = config.get("templates")
    template_paths: List[Path] = []

    if configured_templates:
        logger.debug("Using template list from configuration")
        for filename in configured_templates:
            path = root_directory / filename
            if not path.is_file():
                logger.error(
                    "Configured template '%s' not found at %s; skipping", filename, path
                )
                continue
            template_paths.append(path)
    else:
        logger.debug("No templates specified in configuration; discovering automatically")
        template_paths = discover_templates(root_directory)

    if not template_paths:
        raise RuntimeError(
            "No dashboard templates found to package. "
            "Check configuration or ensure templates exist."
        )

    # Compute version label if not provided
    effective_version = version_label or datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")

    # Construct archive name
    archive_name = f"dashboard-templates-{effective_version}.zip"
    output_dir.mkdir(parents=True, exist_ok=True)
    archive_path = output_dir / archive_name

    plan = PackagePlan(
        root_directory=str(root_directory),
        template_files=[str(p.relative_to(root_directory)) for p in template_paths],
        version_label=effective_version,
        archive_path=str(archive_path),
    )

    logger.debug("Built package plan: %s", plan)
    return plan


def execute_package_plan(plan: PackagePlan) -> None:
    """
    Execute the given PackagePlan by creating a ZIP archive.

    Args:
        plan: PackagePlan describing files to include and archive path.
    """
    root_directory = Path(plan.root_directory)
    archive_path = Path(plan.archive_path)

    logger.info("Creating archive at %s", archive_path)

    try:
        with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
            for relative_file in plan.template_files:
                source_path = root_directory / relative_file
                if not source_path.is_file():
                    logger.error(
                        "Skipping missing file during packaging: %s", source_path
                    )
                    continue
                logger.debug("Adding %s as %s", source_path, relative_file)
                zf.write(source_path, arcname=relative_file)
    except Exception as exc:
        logger.exception("Failed to create archive at %s: %s", archive_path, exc)
        raise

    logger.info("Archive created successfully at %s", archive_path)


# ----------------------------
# CLI handling
# ----------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """
    Parse CLI arguments.

    Args:
        argv: Optional list of arguments (for testing).

    Returns:
        argparse Namespace of parsed args.
    """
    parser = argparse.ArgumentParser(
        description="Package compliance dashboard templates into a distributable ZIP archive."
    )
    parser.add_argument(
        "--config",
        type=str,
        help="Optional path to JSON or YAML configuration file.",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="artifacts",
        help="Directory where the ZIP archive will be created (default: artifacts).",
    )
    parser.add_argument(
        "--version",
        type=str,
        help="Optional version label for the archive (e.g., 1.0.0, build-1234). "
             "If omitted, a UTC timestamp will be used.",
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
    Main CLI entry point.

    Returns:
        Exit code (0 for success, non-zero for failure).
    """
    args = parse_args(argv)
    configure_logging(args.verbose)

    config_path = Path(args.config).resolve() if args.config else None
    output_dir = Path(args.output_dir).resolve()

    try:
        config = load_config(config_path)
        plan = build_package_plan(config, args.version, output_dir)

        logger.info(
            "Packaging %d templates from %s into %s (version=%s)",
            len(plan.template_files),
            plan.root_directory,
            plan.archive_path,
            plan.version_label,
        )

        execute_package_plan(plan)
        return 0
    except Exception as exc:
        logger.exception("Failed to package dashboard templates: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
