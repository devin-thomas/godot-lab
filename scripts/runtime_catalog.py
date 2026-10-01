"""Keep the exported, searchable capability catalog aligned with the design catalog."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "game/labs/catalog.json"


def content() -> str:
    entries = json.loads((ROOT / "planning/catalog.json").read_text(encoding="utf-8"))
    fields = ("id", "title", "wing", "payoff", "mechanism", "limits", "milestone")
    return json.dumps([{key: entry[key] for key in fields} for entry in entries], indent=2) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    options = parser.parse_args()
    expected = content()
    if options.write:
        TARGET.write_text(expected, encoding="utf-8")
    elif not TARGET.is_file() or TARGET.read_text(encoding="utf-8") != expected:
        raise SystemExit("Runtime catalog drift: run python scripts/runtime_catalog.py --write")
    print("PASS runtime catalog: 96 capability descriptions")


if __name__ == "__main__":
    main()
