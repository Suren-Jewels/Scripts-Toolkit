#!/usr/bin/env python3
"""
collect-configs.py

Collects system configuration snapshots for audit evidence:
- OS details, kernel, installed packages (where supported)
- Network configuration, mounted filesystems
- Configurable inclusion/exclusion via config file and CLI
"""

import argparse
import configparser
import datetime
import logging
import os
import platform
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

# -----------------------------
# Defaults
# -----------------------------

DEFAULT_CONFIG_FILE = "./collect-configs.ini"
DEFAULT_OUTPUT_DIR = "/var/tmp/evidence-configs"
DEFAULT_LOG_LEVEL = "INFO"


# -----------------------------
# Logging setup
# -----------------------------

def setup_logger(log_level: str) -> None:
    """Configure root logger with the desired log level and format."""
    numeric_level = getattr(logging, log_level.upper(), logging.INFO)
    logging.basicConfig(
        level=numeric_level,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )
    logging.debug("Logger initialized with level: %s", log_level)


# -----------------------------
# Command execution helper
# -----------------------------

def run_command(command: List[str]) -> str:
    """
    Run a system command safely and return stdout as text.

    - Raises no exceptions; returns an error message on failure.
    - Use for introspection commands (ip, ifconfig, etc.).
    """
    logging.debug("Executing command: %s", " ".join(command))
    try:
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode != 0:
            logging.warning(
                "Command failed (code=%s): %s; stderr=%s",
                result.returncode,
                " ".join(command),
                result.stderr.strip(),
            )
        return result.stdout
    except Exception as exc:  # noqa: BLE001
        logging.error("Failed to execute %s: %s", command, exc)
        return f"ERROR: Failed to execute {command}: {exc}\n"


# -----------------------------
# Configuration loading
# -----------------------------

def load_config(config_file: str) -> configparser.ConfigParser:
    """Load configuration from an INI-style file if it exists."""
    config = configparser.ConfigParser()
    if os.path.exists(config_file):
        logging.info("Loading configuration from %s", config_file)
        config.read(config_file)
    else:
        logging.debug("Config file %s not found; using defaults.", config_file)
    return config


# -----------------------------
# Snapshot functions
# -----------------------------

def write_text_file(output_dir: Path, name: str, content: str) -> None:
    """Write content to a file under output_dir with basic error handling."""
    try:
        output_dir.mkdir(parents=True, exist_ok=True)
        file_path = output_dir / name
        file_path.write_text(content, encoding="utf-8")
        logging.info("Wrote configuration snapshot: %s", file_path)
    except Exception as exc:  # noqa: BLE001
        logging.error("Failed to write snapshot %s: %s", name, exc)


def snapshot_system_info(output_dir: Path) -> None:
    """Collect OS, kernel, Python version, and hardware basics."""
    logging.info("Collecting system information...")
    info_lines = [
        f"Timestamp: {datetime.datetime.utcnow().isoformat()}Z",
        f"System: {platform.system()}",
        f"Node: {platform.node()}",
        f"Release: {platform.release()}",
        f"Version: {platform.version()}",
        f"Machine: {platform.machine()}",
        f"Processor: {platform.processor()}",
        f"Python Version: {platform.python_version()}",
    ]
    write_text_file(output_dir, "system-info.txt", "\n".join(info_lines) + "\n")


def snapshot_network(output_dir: Path) -> None:
    """Collect basic networking details (interfaces, routes)."""
    logging.info("Collecting network configuration...")

    # Try modern commands first, fallback where not available.
    ip_addr = run_command(["ip", "addr"])
    if not ip_addr:
        ip_addr = run_command(["ifconfig"])

    ip_route = run_command(["ip", "route"])

    content = [
        "=== IP ADDR / INTERFACES ===",
        ip_addr,
        "\n=== ROUTES ===",
        ip_route,
    ]
    write_text_file(output_dir, "network-config.txt", "\n".join(content))


def snapshot_filesystems(output_dir: Path) -> None:
    """Collect disk and filesystem information."""
    logging.info("Collecting filesystem information...")
    df_output = run_command(["df", "-h"])
    mount_output = run_command(["mount"])
    content = [
        "=== DISK USAGE (df -h) ===",
        df_output,
        "\n=== MOUNTS (mount) ===",
        mount_output,
    ]
    write_text_file(output_dir, "filesystems.txt", "\n".join(content))


def snapshot_installed_packages(output_dir: Path) -> None:
    """
    Collect installed packages where feasible.

    This is inherently OS-specific. Here we try:
    - dpkg-query (Debian/Ubuntu)
    - rpm (RHEL/CentOS/SUSE)
    - fallback message if neither exists.
    """
    logging.info("Collecting installed packages (best-effort)...")

    if shutil_which("dpkg-query"):
        logging.debug("Using dpkg-query to list packages.")
        pkgs = run_command(["dpkg-query", "-W", "-f", "${Package} ${Version}\n"])
        write_text_file(output_dir, "installed-packages.txt", pkgs)
        return

    if shutil_which("rpm"):
        logging.debug("Using rpm to list packages.")
        pkgs = run_command(["rpm", "-qa"])
        write_text_file(output_dir, "installed-packages.txt", pkgs)
        return

    logging.warning(
        "No known package manager (dpkg/rpm) found; writing placeholder."
    )
    write_text_file(
        output_dir,
        "installed-packages.txt",
        "Package inventory not available on this system.\n",
    )


def shutil_which(cmd: str) -> Optional[str]:
    """Simple wrapper for shutil.which with lazy import to keep top clean."""
    import shutil  # lazy import

    return shutil.which(cmd)


# -----------------------------
# Argument parsing
# -----------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect system configuration snapshots for evidence."
    )
    parser.add_argument(
        "-c",
        "--config",
        default=DEFAULT_CONFIG_FILE,
        help=f"Path to config file (default: {DEFAULT_CONFIG_FILE})",
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
    parser.add_argument(
        "--skip-packages",
        action="store_true",
        help="Skip collection of installed packages snapshot.",
    )
    return parser.parse_args(argv)


# -----------------------------
# Main
# -----------------------------

def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)

    # Setup logging first
    setup_logger(args.log_level)

    # Load config file (can override output-dir or skip-packages)
    config = load_config(args.config)
    output_dir = Path(
        config.get("general", "output_dir", fallback=args.output_dir)
    )
    skip_packages = config.getboolean(
        "general", "skip_packages", fallback=args.skip_packages
    )

    logging.info("Using output directory: %s", output_dir)
    logging.debug("Skip packages: %s", skip_packages)

    try:
        timestamp = datetime.datetime.utcnow().strftime("%Y%m%d-%H%M%S")
        evidence_dir = output_dir / f"config-snapshot-{timestamp}"
        evidence_dir.mkdir(parents=True, exist_ok=True)
        logging.info("Created evidence directory: %s", evidence_dir)

        snapshot_system_info(evidence_dir)
        snapshot_network(evidence_dir)
        snapshot_filesystems(evidence_dir)

        if not skip_packages:
            snapshot_installed_packages(evidence_dir)
        else:
            logging.info("Skipping installed packages snapshot as requested.")

        logging.info("Configuration evidence collection completed successfully.")
        return 0
    except Exception as exc:  # noqa: BLE001
        logging.exception("Unexpected error during config collection: %s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
