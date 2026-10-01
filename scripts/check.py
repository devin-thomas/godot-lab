"""Automated acceptance, with optional rendered evidence and exported-executable proof."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import tempfile

from build import ROOT, build, engine, run


def verify(command: str, name: str, *, rendered: bool = False, exported: bool = False) -> dict:
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    report_path = artifacts / f"{name}.json"
    report_path.unlink(missing_ok=True)
    args = [command]
    if not rendered:
        args.append("--headless")
    if not exported:
        args += ["--path", "game"]
    args += ["--", "--verify", f"--report={report_path.as_posix()}"]
    if rendered:
        args.append(f"--snapshots={(artifacts / 'screens').as_posix()}")
    output = run(args, timeout=120)
    (artifacts / f"{name}.log").write_text(output, encoding="utf-8")
    if "GODOT_LAB_VERIFY PASS" not in output or not report_path.is_file():
        raise RuntimeError("Game never produced its verification receipt")
    report = json.loads(report_path.read_text(encoding="utf-8"))
    if report.get("passed") is not True or len(report.get("checks", [])) < 11:
        raise RuntimeError(f"Acceptance failed: {report}")
    print(f"PASS {name}: {len(report['checks'])} outcome checks")
    restart_path = artifacts / f"{name}-restart.json"
    restart_path.unlink(missing_ok=True)
    restart_args = [command, "--headless"]
    if not exported:
        restart_args += ["--path", "game"]
    restart_args += ["--", "--inspect-save", f"--report={restart_path.as_posix()}"]
    restarted = run(restart_args)
    if "RESTART_GATE PASS" not in restarted or not json.loads(restart_path.read_text())["passed"]:
        raise RuntimeError("A fresh process did not recover all persisted lab seals")
    print(f"PASS {name}: fresh-process persistence")
    return report


def negative_control(godot: str) -> None:
    with tempfile.TemporaryDirectory(prefix="godot-lab-negative-") as temp:
        directory = Path(temp)
        (directory / "project.godot").write_text('config_version=5\n', encoding="utf-8")
        (directory / "invalid.gd").write_text('extends SceneTree\nfunc ???\n', encoding="utf-8")
        result = subprocess.run([godot, "--headless", "--path", temp, "--script", "invalid.gd"],
                                text=True, capture_output=True, timeout=30)
        if "Parse Error" not in result.stdout + result.stderr:
            raise RuntimeError("Negative parse-control did not fail as expected")
    print("PASS parser negative control")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    parser.add_argument("--render", action="store_true")
    parser.add_argument("--export", action="store_true")
    options = parser.parse_args()
    godot = engine(options.godot)
    version = run([godot, "--version"]).strip()
    if not version.startswith("4.7.2.stable"):
        raise RuntimeError(f"Expected tested Godot 4.7.2 stable; found {version}")
    run([godot, "--headless", "--path", "game", "--editor", "--import", "--quit"])
    scripts = run([godot, "--headless", "--path", "game", "--script", "tests/load_scripts.gd"])
    if "SCRIPT_GATE PASS" not in scripts:
        raise RuntimeError("First-party scripts were not all loaded")
    negative_control(godot)
    verify(godot, "headless")
    if options.render:
        verify(godot, "rendered", rendered=True)
        screens = ROOT / "artifacts" / "screens"
        for name in ["motion", "physics", "navigation", "materials", "audio", "persistence"]:
            if not (screens / f"{name}.png").is_file():
                raise RuntimeError(f"Missing rendered evidence for {name}")
    if options.export:
        executable = build(godot)
        verify(str(executable), "exported", exported=True)
    print("PASS Godot Lab automated acceptance")


if __name__ == "__main__":
    main()
