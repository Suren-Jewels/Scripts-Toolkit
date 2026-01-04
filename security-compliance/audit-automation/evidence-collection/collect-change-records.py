#!/usr/bin/env python3
"""
collect-change-records.py

Aggregates change management evidence from:
- Ticketing/export files (CSV/JSON)
- Local change logs (e.g., deployment logs)
Produces a normalized JSON evidence bundle for audits.
"""

import argparse
import csv
import datetime
import json
import logging
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

DEFAULT_CONFIG_FILE = "./collect-change-records.json"
DEFAULT_OUTPUT_DIR = "/var/tmp/evidence-change-records"
DEFAULT_LOG_LEVEL = "INFO"


# -----------------------------
# Logging
# -----------------------------

def setup_logging(level: str) -> None:
    numeric_level = getattr(logging, level.upper(), logging.INFO)
    logging.basicConfig(
        level=numeric_level,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )
    logging.debug("Logging initialized with level %s", level)


# -----------------------------
# Config loading
# -----------------------------

def load_json_config(path: str) -> Dict[str, Any]:
    """
    Load JSON configuration if present.

    Config structure example:
    {
      "ticket_sources": [
        {"type": "csv", "path": "/var/audit/changes.csv"},
        {"type": "json", "path": "/var/audit/changes.json"}
      ],
      "local_change_logs": [
        "/var/log/deployments.log",
        "/var/log/config-changes.log"
      ],
      "output_dir": "/var/tmp/evidence-change-records"
    }
    """
    if not os.path.exists(path):
        logging.debug("Config file %s not found; using defaults.", path)
        return {}

    try:
        with open(path, "r", encoding="utf-8") as fh:
            logging.info("Loading configuration from %s", path)
            return json.load(fh)
    except (OSError, json.JSONDecodeError) as exc:
        logging.error("Failed to load JSON config %s: %s", path, exc)
        return {}


# -----------------------------
# Ticket source parsing
# -----------------------------

def parse_csv_ticket_source(path: Path) -> List[Dict[str, Any]]:
    """Parse a CSV file of change records into a standardized dict list."""
    records: List[Dict[str, Any]] = []
    if not path.exists():
        logging.warning("CSV ticket source not found: %s", path)
        return records

    logging.info("Parsing CSV ticket source: %s", path)
    try:
        with path.open("r", encoding="utf-8") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                record = {
                    "id": row.get("id") or row.get("ticket_id"),
                    "summary": row.get("summary") or row.get("title"),
                    "status": row.get("status"),
                    "change_type": row.get("change_type"),
                    "requested_by": row.get("requested_by"),
                    "implemented_by": row.get("implemented_by"),
                    "start_time": row.get("start_time"),
                    "end_time": row.get("end_time"),
                    "raw_source": "csv",
                    "source_path": str(path),
                    "raw_record": row,
                }
                records.append(record)
    except Exception as exc:  # noqa: BLE001
        logging.error("Failed to parse CSV %s: %s", path, exc)

    return records


def parse_json_ticket_source(path: Path) -> List[Dict[str, Any]]:
    """Parse a JSON file of change records."""
    records: List[Dict[str, Any]] = []
    if not path.exists():
        logging.warning("JSON ticket source not found: %s", path)
        return records

    logging.info("Parsing JSON ticket source: %s", path)
    try:
        with path.open("r", encoding="utf-8") as fh:
            data = json.load(fh)

        # Accept either list of objects or object with "changes" list
        if isinstance(data, dict) and "changes" in data:
            items = data["changes"]
        elif isinstance(data, list):
            items = data
        else:
            logging.warning(
                "JSON structure for %s not recognized; expected list or {\"changes\": [...]}",
                path,
            )
            return records

        for item in items:
            if not isinstance(item, dict):
                continue
            record = {
                "id": item.get("id") or item.get("ticket_id"),
                "summary": item.get("summary") or item.get("title"),
                "status": item.get("status"),
                "change_type": item.get("change_type"),
                "requested_by": item.get("requested_by"),
                "implemented_by": item.get("implemented_by"),
                "start_time": item.get("start_time"),
                "end_time": item.get("end_time"),
                "raw_source": "json",
                "source_path": str(path),
                "raw_record": item,
            }
            records.append(record)
    except Exception as exc:  # noqa: BLE001
        logging.error("Failed to parse JSON %s: %s", path, exc)

    return records


def load_ticket_sources(sources: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Load and parse all configured ticket sources."""
    all_records: List[Dict[str, Any]] = []
    for src in sources:
        src_type = src.get("type")
        src_path = src.get("path")
        if not src_type or not src_path:
            logging.warning("Skipping ticket source with missing type/path: %s", src)
            continue
        path = Path(src_path)
        if src_type == "csv":
            all_records.extend(parse_csv_ticket_source(path))
        elif src_type == "json":
            all_records.extend(parse_json_ticket_source(path))
        else:
            logging.warning("Unknown ticket source type '%s' for path %s", src_type, path)
    return all_records


# -----------------------------
# Local change log collection
# -----------------------------

def read_text_file(path: Path) -> Optional[str]:
    """Read text file content if present."""
    if not path.exists():
        logging.warning("Local change log not found: %s", path)
        return None

    try:
        return path.read_text(encoding="utf-8")
    except Exception as exc:  # noqa: BLE001
        logging.error("Failed to read %s: %s", path, exc)
        return None


def collect_local_change_logs(paths: List[str]) -> Dict[str, str]:
    """Collect raw text of local change logs keyed by filename."""
    collected: Dict[str, str] = {}
    for p in paths:
        path = Path(p)
        content = read_text_file(path)
        if content is not None:
            collected[str(path)] = content
    return collected


# -----------------------------
# Arguments and main
# -----------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect change management evidence into a unified JSON bundle."
    )
    parser.add_argument(
        "-c",
        "--config",
        default=DEFAULT_CONFIG_FILE,
        help=f"Path to JSON config (default: {DEFAULT_CONFIG_FILE})",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=DEFAULT_OUTPUT_DIR,
        help=f"Output directory (default: {DEFAULT_OUTPUT_DIR})",
    )
    parser.add_argument(
        "--log-level",
        default=DEFAULT_LOG_LEVEL,
        help="Log level (DEBUG, INFO, WARNING, ERROR) (default: INFO)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    setup_logging(args.log_level)

    config = load_json_config(args.config)

    output_dir = Path(config.get("output_dir", args.output_dir))
    ticket_sources = config.get("ticket_sources", [])
    local_change_logs = config.get("local_change_logs", [])

    try:
        output_dir.mkdir(parents=True, exist_ok=True)
        logging.info("Using output directory: %s", output_dir)

        timestamp = datetime.datetime.utcnow().strftime("%Y%m%d-%H%M%S")
        evidence_file = output_dir / f"change-evidence-{timestamp}.json"

        logging.info("Loading ticket sources...")
        tickets = load_ticket_sources(ticket_sources)

        logging.info("Collecting local change logs...")
        local_logs = collect_local_change_logs(local_change_logs)

        evidence_bundle = {
            "metadata": {
                "generated_at_utc": datetime.datetime.utcnow().isoformat() + "Z",
                "ticket_source_count": len(ticket_sources),
                "local_change_log_count": len(local_logs),
            },
            "tickets": tickets,
            "local_logs": local_logs,
        }

        evidence_file.write_text(json.dumps(evidence_bundle, indent=2), encoding="utf-8")
        logging.info("Change management evidence written to: %s", evidence_file)
        return 0
    except Exception as exc:  # noqa: BLE001
        logging.exception("Unexpected error during change record collection: %s", exc)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
