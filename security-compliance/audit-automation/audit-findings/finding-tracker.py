#!/usr/bin/env python3
"""
finding-tracker.py

Tracks audit findings and remediation status.

Features:
- Add new findings
- Update existing findings (status, owner, etc.)
- List and filter findings
- Storage via JSON file
- Configurable via CLI arguments and optional config file
"""

import argparse
import json
import logging
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any

# -------------------------
# Data models
# -------------------------


@dataclass
class Finding:
    """Represents a single audit finding."""
    id: str
    title: str
    description: str
    status: str
    owner: str
    severity: str
    created_at: str
    updated_at: str
    due_date: Optional[str] = None
    tags: Optional[List[str]] = None


# -------------------------
# Storage and utilities
# -------------------------


def load_findings(storage_path: Path) -> List[Finding]:
    """
    Load findings from the JSON storage file.

    Returns an empty list if the file does not exist yet.
    """
    if not storage_path.exists():
        logging.debug("Storage file does not exist yet, returning empty findings list.")
        return []

    try:
        with storage_path.open("r", encoding="utf-8") as f:
            raw = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Failed to parse JSON from storage file: %s", exc)
        raise SystemExit(1)

    findings: List[Finding] = []
    for item in raw:
        try:
            findings.append(Finding(**item))
        except TypeError as exc:
            logging.warning("Skipping malformed finding entry: %s | error: %s", item, exc)
    logging.debug("Loaded %d findings from storage.", len(findings))
    return findings


def save_findings(storage_path: Path, findings: List[Finding]) -> None:
    """
    Persist findings to the JSON storage file.
    """
    try:
        with storage_path.open("w", encoding="utf-8") as f:
            json.dump([asdict(finding) for finding in findings], f, indent=2, sort_keys=True)
        logging.debug("Successfully saved %d findings to storage.", len(findings))
    except OSError as exc:
        logging.error("Unable to write findings to storage file: %s", exc)
        raise SystemExit(1)


def find_finding(findings: List[Finding], finding_id: str) -> Optional[Finding]:
    """
    Locate a finding by ID.
    """
    for finding in findings:
        if finding.id == finding_id:
            return finding
    return None


def now_iso() -> str:
    """
    Returns current time in ISO 8601 format.
    """
    return datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


# -------------------------
# Operations
# -------------------------


def op_add(args: argparse.Namespace, storage_path: Path) -> None:
    """
    Add a new finding to storage.
    """
    findings = load_findings(storage_path)

    if find_finding(findings, args.id):
        logging.error("Finding with ID '%s' already exists.", args.id)
        raise SystemExit(1)

    finding = Finding(
        id=args.id,
        title=args.title,
        description=args.description,
        status=args.status,
        owner=args.owner,
        severity=args.severity,
        created_at=now_iso(),
        updated_at=now_iso(),
        due_date=args.due_date,
        tags=args.tags or [],
    )
    findings.append(finding)
    save_findings(storage_path, findings)
    logging.info("Added finding with ID '%s'.", finding.id)


def op_update(args: argparse.Namespace, storage_path: Path) -> None:
    """
    Update fields of an existing finding.
    """
    findings = load_findings(storage_path)
    finding = find_finding(findings, args.id)

    if not finding:
        logging.error("Finding with ID '%s' not found.", args.id)
        raise SystemExit(1)

    # Update fields only if provided to avoid unintentionally overwriting values
    if args.title:
        finding.title = args.title
    if args.description:
        finding.description = args.description
    if args.status:
        finding.status = args.status
    if args.owner:
        finding.owner = args.owner
    if args.severity:
        finding.severity = args.severity
    if args.due_date is not None:
        finding.due_date = args.due_date
    if args.tags is not None:
        finding.tags = args.tags

    finding.updated_at = now_iso()
    save_findings(storage_path, findings)
    logging.info("Updated finding with ID '%s'.", finding.id)


def op_list(args: argparse.Namespace, storage_path: Path) -> None:
    """
    List findings, optionally filtered by status/severity/owner/tag.
    """
    findings = load_findings(storage_path)

    def matches(f: Finding) -> bool:
        """Filter predicate for findings."""
        if args.status and f.status.lower() != args.status.lower():
            return False
        if args.severity and f.severity.lower() != args.severity.lower():
            return False
        if args.owner and f.owner.lower() != args.owner.lower():
            return False
        if args.tag and (not f.tags or args.tag not in f.tags):
            return False
        return True

    filtered = [f for f in findings if matches(f)]
    logging.info("Found %d matching findings.", len(filtered))

    # Output in a simple, machine-readable format (JSON to stdout)
    results: List[Dict[str, Any]] = [asdict(f) for f in filtered]
    print(json.dumps(results, indent=2, sort_keys=True))


# -------------------------
# Config and argument parsing
# -------------------------


def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    """
    Load configuration file if provided.

    Expected minimal structure:
    {
      "storage_path": "/path/to/findings.json",
      "default_status": "OPEN",
      "default_severity": "MEDIUM"
    }
    """
    if not config_path:
        logging.debug("No config file provided, using defaults only.")
        return {}

    if not config_path.exists():
        logging.error("Config file '%s' does not exist.", config_path)
        raise SystemExit(1)

    try:
        with config_path.open("r", encoding="utf-8") as f:
            cfg = json.load(f)
    except json.JSONDecodeError as exc:
        logging.error("Unable to parse config JSON: %s", exc)
        raise SystemExit(1)

    logging.debug("Loaded configuration from '%s'.", config_path)
    return cfg


def build_parser() -> argparse.ArgumentParser:
    """
    Construct the top-level CLI argument parser.
    """
    parser = argparse.ArgumentParser(
        description="Track and manage audit findings.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--config",
        type=Path,
        help="Optional path to JSON config file for defaults."
    )

    parser.add_argument(
        "--storage-path",
        type=Path,
        help="Path to findings storage JSON file (overrides config)."
    )

    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging verbosity level."
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    # add
    add_p = subparsers.add_parser("add", help="Add a new finding.")
    add_p.add_argument("--id", required=True, help="Unique identifier for the finding.")
    add_p.add_argument("--title", required=True, help="Short title for the finding.")
    add_p.add_argument("--description", required=True, help="Detailed description.")
    add_p.add_argument(
        "--status", default=None, help="Status (e.g., OPEN, IN_PROGRESS, CLOSED)."
    )
    add_p.add_argument("--owner", required=True, help="Finding owner (person/team).")
    add_p.add_argument(
        "--severity",
        default=None,
        help="Severity level (e.g., LOW, MEDIUM, HIGH, CRITICAL)."
    )
    add_p.add_argument(
        "--due-date",
        help="Optional due date in ISO format (e.g., 2025-07-01)."
    )
    add_p.add_argument(
        "--tags",
        nargs="+",
        help="Optional list of tags for categorization."
    )

    # update
    upd_p = subparsers.add_parser("update", help="Update an existing finding.")
    upd_p.add_argument("--id", required=True, help="ID of the finding to update.")
    upd_p.add_argument("--title", help="New title.")
    upd_p.add_argument("--description", help="New description.")
    upd_p.add_argument("--status", help="New status.")
    upd_p.add_argument("--owner", help="New owner.")
    upd_p.add_argument("--severity", help="New severity.")
    upd_p.add_argument(
        "--due-date",
        help="New due date in ISO format, or empty string to clear."
    )
    upd_p.add_argument(
        "--tags",
        nargs="*",
        help="New tags; omit this argument to keep existing tags."
    )

    # list
    list_p = subparsers.add_parser("list", help="List findings with optional filters.")
    list_p.add_argument("--status", help="Filter by status.")
    list_p.add_argument("--severity", help="Filter by severity.")
    list_p.add_argument("--owner", help="Filter by owner.")
    list_p.add_argument("--tag", help="Filter by single tag.")

    return parser


def resolve_storage_path(args: argparse.Namespace, config: Dict[str, Any]) -> Path:
    """
    Determine storage path, preferring CLI argument over config,
    falling back to a sensible default.
    """
    if args.storage_path:
        return args.storage_path

    if "storage_path" in config:
        return Path(config["storage_path"])

    # Default to local directory file if nothing is provided
    default_path = Path("findings.json")
    logging.debug("Using default storage path '%s'.", default_path)
    return default_path


def main(argv: Optional[List[str]] = None) -> None:
    """
    Entry point for the CLI.
    """
    parser = build_parser()
    args = parser.parse_args(argv)

    # Initialize logging as early as possible
    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format="%(asctime)s | %(levelname)s | %(message)s",
    )

    config = load_config(args.config)
    storage_path = resolve_storage_path(args, config)

    # Apply defaults for add command if not provided via CLI
    if args.command == "add":
        if args.status is None:
            args.status = config.get("default_status", "OPEN")
        if args.severity is None:
            args.severity = config.get("default_severity", "MEDIUM")

    if args.command == "add":
        op_add(args, storage_path)
    elif args.command == "update":
        # Special handling to allow clearing due_date when empty string given
        if args.due_date == "":
            args.due_date = None
        op_update(args, storage_path)
    elif args.command == "list":
        op_list(args, storage_path)
    else:
        # This should not occur due to `required=True` on subparsers
        parser.error("Unknown command.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logging.warning("Interrupted by user.")
        sys.exit(130)
