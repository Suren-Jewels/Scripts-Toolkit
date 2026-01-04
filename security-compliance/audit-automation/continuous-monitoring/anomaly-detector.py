#!/usr/bin/env python3
"""
anomaly-detector.py

Stateless anomaly detection utility for compliance/security metrics and events.

Responsibilities:
- Ingest events or metrics (JSON lines) from a file or stdin
- Load alert thresholds and anomaly policies from a YAML file
- Flag anomalies when thresholds are breached or patterns are unusual
- Emit structured anomaly records for downstream systems

This module intentionally uses a simple statistical/threshold-based approach
as a baseline; you can plug in more advanced ML-based models where indicated.
"""

import argparse
import json
import logging
import statistics
import sys
from collections import defaultdict, deque
from pathlib import Path
from typing import Any, Deque, Dict, Iterable, List, Optional, Tuple

try:
    import yaml  # type: ignore
except ImportError as exc:
    raise SystemExit(
        "Missing dependency: pyyaml. Install with `pip install pyyaml`."
    ) from exc


# -----------------------------
# Logging setup
# -----------------------------


def setup_logger(verbosity: int) -> logging.Logger:
    """
    Configure logger with dynamic verbosity.

    Parameters
    ----------
    verbosity : int
        0 = WARNING, 1 = INFO, 2+ = DEBUG

    Returns
    -------
    logging.Logger
        Configured logger instance.
    """
    logger = logging.getLogger("anomaly_detector")
    logger.setLevel(logging.DEBUG)

    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)

    if verbosity <= 0:
        log_level = logging.WARNING
    elif verbosity == 1:
        log_level = logging.INFO
    else:
        log_level = logging.DEBUG

    formatter = logging.Formatter(
        "%(asctime)s | %(name)s | %(levelname)s | %(message)s"
    )
    handler.setFormatter(formatter)
    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(log_level)
    return logger


# -----------------------------
# Configuration loading
# -----------------------------


def load_thresholds(path: Path, logger: logging.Logger) -> Dict[str, Any]:
    """
    Load thresholds and anomaly policies from YAML.

    Parameters
    ----------
    path : Path
        Path to YAML threshold configuration.
    logger : logging.Logger
        Logger instance.

    Returns
    -------
    Dict[str, Any]
        Parsed threshold configuration.
    """
    if not path.is_file():
        logger.error("Threshold configuration file does not exist: %s", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            config = yaml.safe_load(f) or {}
        logger.debug("Loaded thresholds config from %s", path)
        return config
    except Exception as exc:
        logger.error("Failed to parse thresholds YAML: %s", exc)
        raise SystemExit(1)


# -----------------------------
# Event ingestion
# -----------------------------


def iter_events_from_file(path: Path, logger: logging.Logger) -> Iterable[Dict[str, Any]]:
    """
    Yield JSON events from a newline-delimited JSON file.

    Parameters
    ----------
    path : Path
        Path to input file.
    logger : logging.Logger
        Logger instance.

    Yields
    ------
    Dict[str, Any]
        Parsed JSON objects.
    """
    if not path.is_file():
        logger.error("Input file does not exist: %s", path)
        raise SystemExit(1)

    try:
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    event = json.loads(line)
                    logger.debug("Read event: %s", event)
                    yield event
                except json.JSONDecodeError as exc:
                    logger.warning("Skipping invalid JSON line: %s | error=%s", line, exc)
    except Exception as exc:
        logger.error("Error while reading events from file: %s", exc)
        raise SystemExit(1)


def iter_events_from_stdin(logger: logging.Logger) -> Iterable[Dict[str, Any]]:
    """
    Yield JSON events from stdin.

    Parameters
    ----------
    logger : logging.Logger
        Logger instance.

    Yields
    ------
    Dict[str, Any]
        Parsed JSON objects.
    """
    logger.info("Reading JSON events from stdin.")
    try:
        for line in sys.stdin:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
                logger.debug("Read event from stdin: %s", event)
                yield event
            except json.JSONDecodeError as exc:
                logger.warning("Skipping invalid JSON line: %s | error=%s", line, exc)
    except Exception as exc:
        logger.error("Error while reading events from stdin: %s", exc)
        raise SystemExit(1)


def get_event_iterator(
    source: str,
    input_file: Optional[Path],
    logger: logging.Logger,
) -> Iterable[Dict[str, Any]]:
    """
    Resolve the correct iterator for event ingestion.

    Parameters
    ----------
    source : str
        Either "file" or "stdin".
    input_file : Optional[Path]
        Required when source="file".
    logger : logging.Logger
        Logger instance.

    Returns
    -------
    Iterable[Dict[str, Any]]
        Event iterator.
    """
    if source == "file":
        if not input_file:
            logger.error("input_file is required when source='file'.")
            raise SystemExit(1)
        return iter_events_from_file(input_file, logger)
    if source == "stdin":
        return iter_events_from_stdin(logger)

    logger.error("Unsupported source: %s", source)
    raise SystemExit(1)


# -----------------------------
# Anomaly detection logic
# -----------------------------


class SlidingWindowStats:
    """
    Maintain a sliding window of numeric values, with summary statistics.

    This class is intentionally simple and can be replaced with more
    performant or feature-rich implementations if needed.
    """

    def __init__(self, window_size: int) -> None:
        if window_size <= 0:
            raise ValueError("window_size must be positive.")

        self.window_size: int = window_size
        self.values: Deque[float] = deque(maxlen=window_size)

    def add(self, value: float) -> None:
        """
        Add a new value to the window.

        Parameters
        ----------
        value : float
            Numeric value to add.
        """
        self.values.append(value)

    def mean_and_std(self) -> Tuple[Optional[float], Optional[float]]:
        """
        Compute the mean and standard deviation for the current window.

        Returns
        -------
        Tuple[Optional[float], Optional[float]]
            (mean, std) where std may be None if fewer than 2 values exist.
        """
        if not self.values:
            return None, None

        if len(self.values) == 1:
            return float(self.values[0]), None

        mean_val = statistics.mean(self.values)
        std_val = statistics.pstdev(self.values)
        return float(mean_val), float(std_val)


def detect_anomaly(
    metric_name: str,
    metric_value: float,
    window_stats: SlidingWindowStats,
    zscore_threshold: float,
    logger: logging.Logger,
) -> bool:
    """
    Detect whether a given metric value is anomalous using a z-score heuristic.

    Parameters
    ----------
    metric_name : str
        Name of the metric being evaluated.
    metric_value : float
        Latest metric value.
    window_stats : SlidingWindowStats
        Sliding window that tracks historic values.
    zscore_threshold : float
        Anomaly threshold in terms of absolute z-score.
    logger : logging.Logger
        Logger instance.

    Returns
    -------
    bool
        True if the value is classified as anomalous; False otherwise.
    """
    mean_val, std_val = window_stats.mean_and_std()

    # If we have insufficient data to compute a standard deviation,
    # we treat early values as non-anomalous and simply warm up the window.
    if mean_val is None or std_val is None or std_val == 0:
        logger.debug(
            "Insufficient variance for anomaly detection on %s; warm-up phase. value=%s",
            metric_name,
            metric_value,
        )
        return False

    zscore = abs(metric_value - mean_val) / std_val
    logger.debug(
        "Metric %s | value=%s mean=%s std=%s zscore=%s threshold=%s",
        metric_name,
        metric_value,
        mean_val,
        std_val,
        zscore,
        zscore_threshold,
    )

    return zscore >= zscore_threshold


def build_anomaly_record(
    event: Dict[str, Any],
    metric_name: str,
    metric_value: float,
    reason: str,
) -> Dict[str, Any]:
    """
    Build a structured anomaly record.

    Parameters
    ----------
    event : Dict[str, Any]
        Original event/metric.
    metric_name : str
        Name of the metric used for anomaly detection.
    metric_value : float
        Observed value that triggered anomaly logic.
    reason : str
        Human-readable explanation.

    Returns
    -------
    Dict[str, Any]
        Anomaly record suitable for JSON serialization.
    """
    return {
        "type": "anomaly",
        "metric": metric_name,
        "metric_value": metric_value,
        "reason": reason,
        "source_event": event,
    }


# -----------------------------
# Main orchestration
# -----------------------------


def parse_args(argv: Optional[Iterable[str]] = None) -> argparse.Namespace:
    """
    Parse CLI arguments.

    Parameters
    ----------
    argv : Optional[Iterable[str]]
        Optional list for testing.

    Returns
    -------
    argparse.Namespace
        Parsed arguments.
    """
    parser = argparse.ArgumentParser(description="Compliance anomaly detector.")

    parser.add_argument(
        "--thresholds",
        required=True,
        type=Path,
        help="Path to alert thresholds YAML.",
    )

    parser.add_argument(
        "--source",
        choices=["file", "stdin"],
        default="stdin",
        help="Event source: file or stdin.",
    )

    parser.add_argument(
        "--input-file",
        type=Path,
        help="Input file path when --source=file.",
    )

    parser.add_argument(
        "--metric-field",
        default="count",
        help="Field in event representing numeric metric value.",
    )

    parser.add_argument(
        "--metric-name",
        default="generic_metric",
        help="Name to assign to the metric for reporting.",
    )

    parser.add_argument(
        "--window-size",
        type=int,
        default=20,
        help="Sliding window size for baseline computations.",
    )

    parser.add_argument(
        "--zscore-threshold",
        type=float,
        default=3.0,
        help="Absolute z-score at or above which values are anomalous.",
    )

    parser.add_argument(
        "--output",
        default="stdout",
        help="Output destination: 'stdout' or path to a JSON lines file.",
    )

    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (-v, -vv).",
    )

    return parser.parse_args(list(argv) if argv is not None else None)


def main() -> None:
    """
    Entry point for anomaly detection pipeline.
    """
    args = parse_args()
    logger = setup_logger(args.verbose)

    logger.info("Starting anomaly detector.")
    logger.debug("Arguments: %s", args)

    thresholds_config = load_thresholds(args.thresholds, logger)

    # Override CLI zscore_threshold/window-size from config if present.
    metric_cfg = thresholds_config.get("anomaly_detection", {})
    window_size = int(metric_cfg.get("window_size", args.window_size))
    zscore_threshold = float(metric_cfg.get("zscore_threshold", args.zscore_threshold))

    logger.info(
        "Using window_size=%s and zscore_threshold=%s",
        window_size,
        zscore_threshold,
    )

    stats = SlidingWindowStats(window_size=window_size)
    event_iter = get_event_iterator(args.source, args.input_file, logger)

    output_path: Optional[Path] = None
    if args.output != "stdout":
        output_path = Path(args.output)
        try:
            # Truncate file at start to avoid unbounded growth.
            output_path.write_text("", encoding="utf-8")
        except Exception as exc:
            logger.error("Failed to initialize output file: %s", exc)
            raise SystemExit(1)

    def emit(record: Dict[str, Any]) -> None:
        serialized = json.dumps(record, separators=(",", ":"), sort_keys=True)
        if output_path is None:
            print(serialized)
        else:
            try:
                with output_path.open("a", encoding="utf-8") as f:
                    f.write(serialized + "\n")
            except Exception as exc_inner:
                logger.error("Failed to write anomaly record: %s", exc_inner)
                raise SystemExit(1)

    for event in event_iter:
        raw_value = event.get(args.metric_field)
        # Only process numeric metric values.
        try:
            metric_value = float(raw_value)
        except (TypeError, ValueError):
            logger.debug(
                "Skipping event with non-numeric metric field '%s': %s",
                args.metric_field,
                event,
            )
            continue

        stats.add(metric_value)

        if detect_anomaly(
            metric_name=args.metric_name,
            metric_value=metric_value,
            window_stats=stats,
            zscore_threshold=zscore_threshold,
            logger=logger,
        ):
            reason = (
                f"Metric '{args.metric_name}' value {metric_value} "
                f"exceeds z-score threshold {zscore_threshold}."
            )
            anomaly_record = build_anomaly_record(
                event=event,
                metric_name=args.metric_name,
                metric_value=metric_value,
                reason=reason,
            )
            emit(anomaly_record)

    logger.info("Anomaly detection completed.")


if __name__ == "__main__":
    main()
