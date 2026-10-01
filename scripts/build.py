"""Build the playable Windows release using the installed matching Godot templates."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def engine(value: str | None = None) -> str:
    command = value or os.environ.get("GODOT") or shutil.which("godot_console") or shutil.which("godot")
    if not command:
        raise RuntimeError("Godot 4.7.2 is required; pass --godot or set GODOT")
    return command


def run(command: list[str], *, timeout: int = 180) -> str:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    output = result.stdout + result.stderr
    if result.returncode or "ERROR:" in output or "SCRIPT ERROR" in output:
        raise RuntimeError(f"Command failed ({result.returncode}): {command}\n{output}")
    return output


def build(godot: str) -> Path:
    version = json.loads((ROOT / "package.json").read_text(encoding="utf-8"))["version"]
    if not isinstance(version, str) or not all(part.isdigit() for part in version.split(".")) or len(version.split(".")) != 3:
        raise RuntimeError("Build version must contain three numeric components")
    output = ROOT / "dist" / f"GodotLab-{version}.exe"
    output.parent.mkdir(exist_ok=True)
    run([godot, "--headless", "--path", "game", "--editor", "--import", "--quit"])
    run([godot, "--headless", "--path", "game", "--export-release", "Windows Desktop", str(output)])
    if not output.is_file() or output.stat().st_size < 1_000_000:
        raise RuntimeError("Export did not produce a Windows executable")
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    with output.open("rb") as binary:
        digest = hashlib.file_digest(binary, "sha256").hexdigest()
    (artifacts / "build.json").write_text(json.dumps({
        "path": str(output.relative_to(ROOT)), "bytes": output.stat().st_size,
        "sha256": digest,
        "engine": run([godot, "--version"]).strip(), "signed": False,
    }, indent=2) + "\n", encoding="utf-8")
    return output


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    arguments = parser.parse_args()
    print(build(engine(arguments.godot)))
