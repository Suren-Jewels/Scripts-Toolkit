#!/usr/bin/env python3
"""
CUI Data Classifier
Classifies data as CUI / non‑CUI based on simple rules and labels.
"""

import argparse
import json
from pathlib import Path

CUI_KEYWORDS = [
    "for official use only",
    "controlled unclassified",
    "cui",
    "export controlled",
    "itars"
]

def classify_text(content: str) -> str:
    lowered = content.lower()
    for kw in CUI_KEYWORDS:
        if kw in lowered:
            return "CUI"
    return "NON-CUI"

def main():
    parser = argparse.ArgumentParser(description="Classify data as CUI / NON‑CUI.")
    parser.add_argument("--input", required=True, help="Input text file")
    parser.add_argument("--output", required=False, help="Output classification JSON")
    args = parser.parse_args()

    path = Path(args.input)
    if not path.exists():
        print(f"[ERROR] Input file not found: {path}")
        raise SystemExit(1)

    content = path.read_text(encoding="utf-8", errors="ignore")
    label = classify_text(content)

    result = {
        "file": str(path),
        "classification": label
    }

    if args.output:
        out_path = Path(args.output)
        out_path.write_text(json.dumps(result, indent=2))
        print(f"[RESULT] Classification written → {out_path}")
    else:
        print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
