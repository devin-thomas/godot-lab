#!/usr/bin/env python3
"""Regenerate or verify the canonical source fingerprint for the data labs."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


SOURCE_PATHS = (
    "res://labs/modules/data_labs.gd",
    "res://labs/data/worker_coordinator.gd",
    "res://labs/data/golden_comparator.gd",
)


def manifest_bytes(project_root: Path) -> bytes:
    files: dict[str, str] = {}
    for resource_path in SOURCE_PATHS:
        source_path = project_root / resource_path.removeprefix("res://")
        source_bytes = source_path.read_bytes()
        if b"\r" in source_bytes:
            raise ValueError(f"Source must use LF line endings: {resource_path}")
        files[resource_path] = hashlib.sha256(source_bytes).hexdigest()
    canonical = "".join(f"{path}:{files[path]}\n" for path in sorted(files))
    manifest = {
        "algorithm": "sha256-source-set-v1",
        "files": files,
        "fingerprint": hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
    }
    return (json.dumps(manifest, indent=2) + "\n").encode("utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail if the checked-in manifest is stale")
    arguments = parser.parse_args()
    project_root = Path(__file__).resolve().parents[2]
    manifest_path = project_root / "labs/data/data_labs_fingerprint.json"
    expected = manifest_bytes(project_root)
    if arguments.check:
        if not manifest_path.exists() or manifest_path.read_bytes() != expected:
            print("DATA_LABS_FINGERPRINT_STALE")
            return 1
        print("DATA_LABS_FINGERPRINT_OK")
        return 0
    manifest_path.write_bytes(expected)
    print("DATA_LABS_FINGERPRINT_UPDATED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
