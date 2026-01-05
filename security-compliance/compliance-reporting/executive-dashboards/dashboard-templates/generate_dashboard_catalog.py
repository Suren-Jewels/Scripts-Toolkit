#!/usr/bin/env python3
"""
generate_dashboard_catalog.py

Scan the dashboard-templates directory and generate a machine-readable catalog
describing available compliance dashboard templates.

The catalog is useful for:
- Feeding into higher-level automation (e.g., deployment pipelines)
- Providing a simple index for portals or documentation generators
- Ensuring consistent metadata across Grafana, Power BI, and Tableau templates

Features:
- Configurable root directory and output path via CLI or config file
- JSON (default) catalog output; optional YAML if PyYAML is installed
- Robust logging and error handling
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # YAML is optional


# ----------------------------
# Data models
# ----------------------------

@dataclass
class DashboardTemplateMetadata:
    """Metadata for a single dashboard template."""
    name: str
    filename: str
    type: str
    full_path: str
    size_bytes: int
    modified_utc: str


@dataclass
class DashboardCatalog:
    """Collection of dashboard template metadata."""
    root_directory: str
    generated_utc: str
    templates: List[DashboardTemplateMetadata]


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


logger = logging.getLogger("dashboard_catalog_generator")


# ----------------------------
# Configuration loading
# ----------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load configuration from a JSON or YAML file if provided.

    Config keys:
    - root_directory: directory containing the templates
    - templates: optional explicit list of templates; if omitted, auto-infers by extension
      templates:
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
        Configuration dictionary.
    """
    default_config: Dict[str, Any] = {
        "root_directory": "compliance-reporting/executive-dashboards/dashboard-templates",
        "templates": None,  # If None, we will infer by extension
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
# Template discovery and catalog generation
# ----------------------------

def infer_template_type_from_extension(path: Path) -> str:
    """
    Infer template type (grafana/powerbi/tableau/unknown) based on file extension.

    Args:
        path: Path to the template file.

    Returns:
        Inferred template type.
    """
    ext = path.suffix.lower()

    if ext == ".json":
        return "grafana"
    if ext == ".pbix":
        return "powerbi"
    if ext in (".twb", ".twbx"):
        return "tableau"
    return "unknown"


def build_metadata_from_path(path: Path, name: Optional[str] = None, type_hint: Optional[str] = None) -> DashboardTemplateMetadata:
    """
    Build DashboardTemplateMetadata for a given path.

    Args:
        path: Path to the template file.
        name: Optional logical name; if omitted, inferred from filename.
        type_hint: Optional explicit type; if omitted, inferred from extension.

    Returns:
        DashboardTemplateMetadata instance.

    Raises:
        FileNotFoundError if the path does not exist or is not a file.
    """
    if not path.is_file():
        raise FileNotFoundError(f"Template file does not exist: {path}")

    size_bytes = path.stat().st_size
    modified = datetime.utcfromtimestamp(path.stat().st_mtime).isoformat() + "Z"

    effective_name = name or path.stem
    template_type = type_hint or infer_template_type_from_extension(path)

    return DashboardTemplateMetadata(
        name=effective_name,
        filename=path.name,
        type=template_type,
        full_path=str(path.resolve()),
        size_bytes=size_bytes,
        modified_utc=modified,
    )


def generate_catalog(config: Dict[str, Any]) -> DashboardCatalog:
    """
    Generate a dashboard catalog based on the provided configuration.

    Args:
        config: Configuration dictionary.

    Returns:
        DashboardCatalog instance.

    Raises:
        NotADirectoryError if root_directory does not exist or is not a directory.
    """
    root_directory = Path(config["root_directory"]).resolve()

    if not root_directory.is_dir():
        raise NotADirectoryError(
            f"Dashboard templates directory does not exist: {root_directory}"
        )

    logger.info("Generating dashboard catalog from %s", root_directory)

    explicit_templates = config.get("templates")

    metadata_list: List[DashboardTemplateMetadata] = []

    if explicit_templates:
        logger.debug("Using explicit template definitions from configuration")
        for template_def in explicit_templates:
            filename = template_def["filename"]
            template_name = template_def.get("name")
            template_type = template_def.get("type")

            path = root_directory / filename
            logger.debug("Processing template definition %s at %s", template_name, path)

            try:
                meta = build_metadata_from_path(
                    path=path,
                    name=template_name,
                    type_hint=template_type,
                )
                metadata_list.append(meta)
            except FileNotFoundError as exc:
                logger.error("Template file missing for catalog: %s", exc)
    else:
        logger.debug("No explicit templates configured; inferring by extension")
        for path in root_directory.iterdir():
            if not path.is_file():
                continue

            # Only consider known dashboard extensions
            if path.suffix.lower() not in {".json", ".pbix", ".twb", ".twbx"}:
                logger.debug("Skipping non-dashboard file: %s", path)
                continue

            try:
                meta = build_metadata_from_path(path)
                metadata_list.append(meta)
            except FileNotFoundError as exc:
                logger.error("Unexpected missing file during catalog generation: %s", exc)

    generated_utc = datetime.utcnow().isoformat() + "Z"

    return DashboardCatalog(
        root_directory=str(root_directory),
        generated_utc=generated_utc,
        templates=metadata_list,
    )


# ----------------------------
# CLI handling
# ----------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """
    Parse CLI arguments.

    Args:
        argv: Optional list of CLI args (for testing).

    Returns:
        argparse Namespace of parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Generate a catalog of compliance dashboard templates."
    )
    parser.add_argument(
        "--config",
        type=str,
        help="Optional path to JSON or YAML configuration file.",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=str,
        required=True,
        help="Path to write the catalog (JSON or YAML based on extension).",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="count",
        default=0,
        help="Increase verbosity (use -v, -vv).",
    )
    return parser.parse_args(argv)


def serialize_catalog(catalog: DashboardCatalog, output_path: Path) -> None:
    """
    Serialize the dashboard catalog to the requested output path.

    - If extension is .yaml/.yml, YAML is used (requires PyYAML).
    - Otherwise, JSON is used.

    Args:
        catalog: DashboardCatalog instance.
        output_path: Destination file path.
    """
    catalog_dict = {
        "root_directory": catalog.root_directory,
        "generated_utc": catalog.generated_utc,
        "templates": [asdict(t) for t in catalog.templates],
    }

    if output_path.suffix.lower() in (".yaml", ".yml"):
        if yaml is None:
            raise RuntimeError(
                "PyYAML is required for YAML output. Install with `pip install pyyaml`."
            )
        text = yaml.safe_dump(catalog_dict, sort_keys=False)
    else:
        text = json.dumps(catalog_dict, indent=2)

    output_path.write_text(text + "\n", encoding="utf-8")
    logger.info("Dashboard catalog written to %s", output_path)


def main(argv: Optional[List[str]] = None) -> int:
    """
    Main CLI entry point.

    Returns:
        Exit code (0 for success, non-zero for failure).
    """
    args = parse_args(argv)
    configure_logging(args.verbose)

    config_path = Path(args.config).resolve() if args.config else None
    output_path = Path(args.output).resolve()

    try:
        config = load_config(config_path)
        catalog = generate_catalog(config)
        serialize_catalog(catalog, output_path)
        return 0
    except Exception as exc:
        logger.exception("Failed to generate dashboard catalog: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
