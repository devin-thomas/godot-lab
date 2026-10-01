"""Verify a committed public-only source archive with no sibling repository present."""
from __future__ import annotations

import argparse
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import zipfile

from build import ROOT, engine


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    arguments = parser.parse_args()
    godot = engine(arguments.godot)
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    archive = subprocess.check_output(["git", "archive", "--format=zip", revision], cwd=ROOT)
    with tempfile.TemporaryDirectory(prefix="godot-lab-public-") as temporary:
        checkout = Path(temporary).resolve()
        if not checkout.is_relative_to(Path(tempfile.gettempdir()).resolve()):
            raise RuntimeError("Temporary source directory is outside the intended scratch root")
        with zipfile.ZipFile(io.BytesIO(archive)) as source:
            for member in source.infolist():
                if not (checkout / member.filename).resolve().is_relative_to(checkout):
                    raise RuntimeError("Source archive contains an escaping path")
            source.extractall(checkout)
        planning = subprocess.run([sys.executable, "scripts/plan.py", "--check", "--self-test"],
                                  cwd=checkout, text=True, capture_output=True, timeout=60)
        if planning.returncode:
            raise RuntimeError(planning.stdout + planning.stderr)
        planning_report = json.loads(planning.stdout.strip())
        if planning_report.get("result") != "passed":
            raise RuntimeError("Public archive planning validation did not produce a passing report")
        result = subprocess.run([sys.executable, "scripts/check.py", "--godot", godot],
                                cwd=checkout, text=True, capture_output=True, timeout=180)
        if result.returncode or "PASS Godot Lab automated acceptance" not in result.stdout:
            raise RuntimeError(result.stdout + result.stderr)
        evidence = json.loads((checkout / "artifacts/headless.json").read_text(encoding="utf-8"))
        expanded = json.loads((checkout / "artifacts/wave-logic.json").read_text(encoding="utf-8"))
        report = {"passed": True, "public_commit": revision, "sibling_dependencies": [],
                  "checks": len(evidence["checks"]), "engine": evidence["engine"],
                  "fresh_process_restart": True, "planning": planning_report,
                  "expanded": expanded}
        output = ROOT / "artifacts" / "public-source.json"
        output.parent.mkdir(exist_ok=True)
        output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(f"PASS public-only source: {revision}, {len(evidence['checks'])} checks plus restart")


if __name__ == "__main__":
    main()
