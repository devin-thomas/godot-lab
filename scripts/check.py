"""Automated acceptance, with optional rendered evidence and exported-executable proof."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import re
import sys

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


def expanded_gates(godot: str) -> dict:
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    run([sys.executable, "game/labs/data/update_fingerprint.py", "--check"])
    gates = {}
    for name, marker in [("domain", "DOMAIN_GATE"), ("storage_jobs", "STORAGE_JOBS_GATE"),
                         ("systems", "SYSTEMS_GATE"), ("visual_labs", "VISUAL_LABS_GATE"),
                         ("host", "HOST_GATE"), ("data_labs", "DATA_LABS_GATE")]:
        output = run([godot, "--headless", "--path", "game", "--script", f"tests/{name}_gate.gd",
                      "--", f"--report={(artifacts / (name + '-gate.json')).as_posix()}"], timeout=120)
        (artifacts / (name + "-gate.log")).write_text(output, encoding="utf-8")
        if marker not in output:
            raise RuntimeError(f"Missing gate receipt: {name}")
        counts = re.search(r"(?:checks[=:]\s*(\d+)|(\d+)\s+checks)", output)
        count = int(next(value for value in counts.groups() if value)) if counts else None
        if name == "domain":
            domain = json.loads((artifacts / "domain-gate.json").read_text(encoding="utf-8"))
            if domain.get("ok") is not True:
                raise RuntimeError("Domain gate did not pass")
            count = len(domain["checks"])
        if count is None or count < 1:
            raise RuntimeError(f"Missing assertion count: {name}")
        gates[name] = {"passed": True, "checks": count}
        print(f"PASS expanded {name} gate")
    catalog = run([sys.executable, "scripts/runtime_catalog.py"])
    if "PASS runtime catalog" not in catalog:
        raise RuntimeError("Runtime catalog drift")
    gates["host_modules"] = verify_modules(godot, "modules-headless")
    run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_lab_cli.py"])
    run([sys.executable, "tests/live_api_gate.py", "--godot", godot])
    live_report = json.loads((artifacts / "live-api-gate.json").read_text(encoding="utf-8"))
    if not live_report.get("ok"):
        raise RuntimeError("Live API/CLI/MCP gate failed")
    gates["live_api"] = {"passed": True, "checks": len(live_report["checks"])}
    print("PASS live API/CLI/MCP against owned game process")
    (artifacts / "wave-logic.json").write_text(json.dumps(gates, indent=2) + "\n", encoding="utf-8")
    print(f"PASS expanded host: {gates['host_modules']['labs']} prototypes / {gates['host_modules']['checks']} checks")
    return gates


def verify_modules(command: str, name: str, *, rendered: bool = False, exported: bool = False) -> dict:
    artifacts = ROOT / "artifacts"
    artifacts.mkdir(exist_ok=True)
    report_path = artifacts / (name + ".json")
    report_path.unlink(missing_ok=True)
    args = [command]
    if not rendered:
        args.append("--headless")
    if not exported:
        args += ["--path", "game"]
    args += ["--", "--module-verify", f"--report={report_path.as_posix()}"]
    if rendered:
        snapshots = artifacts / "prototype-screens"
        snapshots.mkdir(exist_ok=True)
        args.append(f"--snapshots={snapshots.as_posix()}")
    output = run(args, timeout=180)
    (artifacts / (name + ".log")).write_text(output, encoding="utf-8")
    report = json.loads(report_path.read_text(encoding="utf-8"))
    if "MODULE_GATE PASS" not in output or not report.get("passed"):
        raise RuntimeError("Expanded host scenarios failed")
    expected = report["expected_module_ids"]
    if sorted(item["lab"] for item in report["prototype_results"]) != sorted(expected):
        raise RuntimeError("Registered prototype coverage is incomplete")
    result = {"passed": True, "labs": len(report["prototype_results"]),
              "checks": sum(len(item["checks"]) for item in report["prototype_results"])}
    print(f"PASS {name}: {result['labs']} prototypes / {result['checks']} checks")
    return result


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
    expanded_gates(godot)
    verify(godot, "headless")
    if options.render:
        rendered_visual = run([godot, "--path", "game", "--script", "tests/visual_labs_gate.gd"])
        (ROOT / "artifacts/visual_labs-rendered.log").write_text(rendered_visual, encoding="utf-8")
        if "VISUAL_LABS_GATE PASS" not in rendered_visual:
            raise RuntimeError("Rendered visual mechanism gate failed")
        verify_modules(godot, "modules-rendered", rendered=True)
        verify(godot, "rendered", rendered=True)
        screens = ROOT / "artifacts" / "screens"
        for name in ["motion", "physics", "navigation", "materials", "audio", "persistence"]:
            if not (screens / f"{name}.png").is_file():
                raise RuntimeError(f"Missing rendered evidence for {name}")
    if options.export:
        executable = build(godot)
        verify_modules(str(executable), "modules-exported", exported=True)
        verify(str(executable), "exported", exported=True)
    print("PASS Godot Lab automated acceptance")


if __name__ == "__main__":
    main()
