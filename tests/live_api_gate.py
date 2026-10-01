"""Qualify the real opt-in host API using owned child processes and loopback sockets."""
from __future__ import annotations

import argparse
import http.client
import json
import os
from pathlib import Path
import secrets
import socket
import subprocess
import sys
import tempfile
import time
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from scripts.build import engine
from scripts.lab_cli import ClientError, request_api


def free_port() -> int:
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def raw_request(port: int, pieces: list[bytes]) -> tuple[int, dict[str, Any]]:
    with socket.create_connection(("127.0.0.1", port), timeout=4) as connection:
        connection.settimeout(4)
        for piece in pieces:
            connection.sendall(piece)
            if len(pieces) > 1:
                time.sleep(0.03)
        chunks = bytearray()
        while len(chunks) <= 300000:
            received = connection.recv(16384)
            if not received:
                break
            chunks.extend(received)
    header, body = bytes(chunks).split(b"\r\n\r\n", 1)
    return int(header.split(b" ")[1]), json.loads(body)


def http_request(port: int, path: str, token: str = "", payload: dict[str, Any] | None = None) -> tuple[int, dict[str, Any]]:
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=4)
    headers = {"Connection": "close"}
    if token:
        headers["Authorization"] = "Bearer " + token
    body = None
    if payload is not None:
        body = json.dumps(payload)
        headers["Content-Type"] = "application/json"
    try:
        connection.request("POST" if body is not None else "GET", path, body=body, headers=headers)
        response = connection.getresponse()
        return response.status, json.loads(response.read(300000))
    finally:
        connection.close()


def stop_child(child: subprocess.Popen[bytes]) -> None:
    if child.poll() is None:
        if os.name == "nt":
            # The Godot console launcher can own a second engine process.
            result = subprocess.run(["taskkill", "/PID", str(child.pid), "/T", "/F"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
            if result.returncode and child.poll() is None:
                raise RuntimeError("CHILD_TERMINATION_FAILED")
        else:
            child.terminate()
        try:
            child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            child.kill()
            child.wait(timeout=5)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    parser.add_argument("--report", default="artifacts/live-api-gate.json")
    args = parser.parse_args()
    checks: list[dict[str, Any]] = []
    def check(name: str, passed: bool) -> None:
        checks.append({"name": name, "passed": bool(passed)})
        if not passed:
            raise RuntimeError(name)

    command = [engine(args.godot), "--headless", "--path", str(ROOT / "game")]
    port = free_port()
    token = secrets.token_urlsafe(32)
    environment = os.environ.copy()
    environment["GODOT_LAB_API_TOKEN"] = token
    environment["GODOT_LAB_API_PORT"] = str(port)
    error_code = ""
    run_id = ""
    with tempfile.TemporaryDirectory(prefix="godot-lab-live-gate-") as temporary:
        log_path = Path(temporary) / "child.log"
        with log_path.open("wb") as log:
            child = subprocess.Popen(command, cwd=ROOT, env=environment, stdout=log, stderr=subprocess.STDOUT, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
            try:
                deadline = time.monotonic() + 20
                ready = None
                while time.monotonic() < deadline:
                    if child.poll() is not None:
                        raise RuntimeError("CHILD_EXITED_BEFORE_READY")
                    try:
                        ready = request_api(f"http://127.0.0.1:{port}", "/health", timeout=1)
                        break
                    except ClientError:
                        time.sleep(0.1)
                check("explicit child listener reports actual service identity", ready is not None and ready.get("service") == "godot-lab-live")
                run_id = str(ready["run_id"])
                startup = [json.loads(line.removeprefix("LIVE_API ")) for line in log_path.read_text(encoding="utf-8", errors="replace").splitlines() if line.startswith("LIVE_API ")]
                check("health run identity matches owned child startup", bool(startup) and startup[-1].get("run_id") == run_id and startup[-1].get("bound_port") == port)
                status, missing = http_request(port, "/v1/state")
                check("no credentials refused", status == 401 and missing.get("code") == "UNAUTHORIZED")
                status, wrong = http_request(port, "/v1/operations", "wrong-credential")
                check("wrong credentials refused", status == 401 and wrong.get("code") == "UNAUTHORIZED")
                status, operations = http_request(port, "/v1/operations", token)
                check("authenticated descriptors include host operation", status == 200 and any(item["name"] == "host.enter" for item in operations["operations"]))
                status, before = http_request(port, "/v1/state", token)
                check("authenticated observation uses same run", status == 200 and before["run_id"] == run_id and isinstance(before["state"], dict))
                status, unknown = http_request(port, "/v1/operations", token, {"operation": "does.not.exist", "arguments": {}, "request_id": "unknown"})
                check("unknown mutation rejected by domain spine", status == 409 and unknown["code"] == "UNKNOWN_OPERATION")
                bounded_observations = True
                for index in range(40):
                    status, observation = http_request(port, "/v1/operations", token, {"operation": "host.observe", "arguments": {}, "request_id": f"observe-{index}"})
                    result = observation.get("result", {})
                    bus_snapshot = result.get("operation_bus", {})
                    bounded_observations = bounded_observations and status == 200 and observation.get("ok") is True and len(json.dumps(observation)) <= 32768 and "receipts" not in bus_snapshot and "events" not in bus_snapshot and "last_receipt" not in result
                check("40 real host observations exclude recursive history and stay bounded", bounded_observations)
                request = {"operation": "host.enter", "arguments": {"id": "LAB-013"}, "request_id": "enter-lab"}
                status, entered = http_request(port, "/v1/operations", token, request)
                check("live operation enters real module", status == 200 and entered["ok"])
                status, retry = http_request(port, "/v1/operations", token, request)
                check("same request retry preserves revision and receipt", status == 200 and retry == entered)
                status, state = http_request(port, "/v1/state", token)
                check("host state observes actual entered module", state["state"]["lab"] == "LAB-013")
                current_revision = int(state["state"]["operation_bus"]["revision"])
                stale = {"operation": "ui.set_setting", "arguments": {"enabled": True}, "request_id": "stale", "expected_revision": current_revision - 1}
                status, conflict = http_request(port, "/v1/operations", token, stale)
                check("stale revision refused at same host", status == 409 and conflict["code"] == "REVISION_CONFLICT")
                action = {"operation": "ui.set_setting", "arguments": {"enabled": True}, "request_id": "set-setting", "expected_revision": current_revision}
                status, applied = http_request(port, "/v1/operations", token, action)
                check("module mutation applies through shared handler", status == 200 and applied["ok"] and applied["revision"] == current_revision + 1)
                status, after_action = http_request(port, "/v1/state", token)
                check("real module setting changes once after stale rejection", status == 200 and after_action["state"]["module"]["setting"] is True and after_action["state"]["module"]["activations"] == 1)
                cli_retry = subprocess.run([sys.executable, str(ROOT / "scripts/lab_cli.py"), "--url", f"http://127.0.0.1:{port}", "submit", "--file", "-"], input=json.dumps(action), env=environment, cwd=ROOT, capture_output=True, text=True, timeout=8)
                check("actual CLI retry shares live mutation receipt", cli_retry.returncode == 0 and json.loads(cli_retry.stdout) == applied)
                status, events = http_request(port, "/v1/events?after=0", token)
                check("bounded events expose actual applied mutations", status in (200, 409) and events["code"] in ("OK", "CURSOR_EXPIRED"))
                fragmented = (f"GET /v1/state HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nAuthorization: Bearer {token}\r\n\r\n").encode()
                status, response = raw_request(port, [fragmented[:13], fragmented[13:45], fragmented[45:]])
                check("fragmented headers reassemble correctly", status == 200 and response["run_id"] == run_id)
                prefix = f"POST /v1/operations HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nAuthorization: Bearer {token}\r\nContent-Type: application/json\r\n"
                body = json.dumps({"operation": "ui.set_setting", "arguments": {"enabled": False}, "request_id": "fragmented-body"}).encode()
                header = (prefix + f"Content-Length: {len(body)}\r\n\r\n").encode()
                status, response = raw_request(port, [header + body[:7], body[7:35], body[35:]])
                check("fragmented body applies one real operation", status == 200 and response["ok"])
                status, fragmented_state = http_request(port, "/v1/state", token)
                check("fragmented operation has visible semantic consequence", status == 200 and fragmented_state["state"]["module"]["setting"] is False and fragmented_state["state"]["module"]["activations"] == 2)
                status, response = raw_request(port, [(prefix + "Content-Length: 65537\r\n\r\n").encode()])
                check("oversized body refused before buffering", status == 413 and response["code"] == "REQUEST_TOO_LARGE")
                status, response = raw_request(port, [(prefix + "Content-Length: 0\r\nContent-Length: 0\r\n\r\n").encode()])
                check("ambiguous duplicate lengths refused", status == 400 and response["code"] == "DUPLICATE_HEADER")
                status, response = raw_request(port, [(prefix + "Transfer-Encoding: chunked\r\n\r\n").encode()])
                check("chunked transfer refused", status == 400 and response["code"] == "UNSUPPORTED_TRANSFER")
                duplicate = b'{"operation":"host.hub","operation":"host.hub","arguments":{},"request_id":"duplicate"}'
                status, response = raw_request(port, [(prefix + f"Content-Length: {len(duplicate)}\r\n\r\n").encode() + duplicate])
                check("duplicate executable JSON keys refused", status == 400 and response["code"] == "DUPLICATE_JSON_KEY")
                invalid_utf8 = b'{"operation":"\xff"}'
                status, response = raw_request(port, [(prefix + f"Content-Length: {len(invalid_utf8)}\r\n\r\n").encode() + invalid_utf8])
                check("invalid UTF8 rejected without decoder error", status == 400 and response["code"] == "INVALID_JSON")
                status, response = raw_request(port, [(f"GET /../v1/state HTTP/1.1\r\nHost: localhost\r\n\r\n").encode()])
                check("path traversal refused", status == 400 and response["code"] == "INVALID_PATH")
                client_result = subprocess.run([sys.executable, str(ROOT / "scripts/lab_cli.py"), "--url", f"http://127.0.0.1:{port}", "state"], env=environment, cwd=ROOT, capture_output=True, text=True, timeout=8)
                check("actual CLI reads same live host", client_result.returncode == 0 and json.loads(client_result.stdout)["run_id"] == run_id and token not in client_result.stdout + client_result.stderr)
                mcp_messages = [{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2025-11-25", "capabilities": {}, "clientInfo": {"name": "live-gate", "version": "1"}}},
                                {"jsonrpc": "2.0", "method": "notifications/initialized"},
                                {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
                                {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "lab_state", "arguments": {}}},
                                {"jsonrpc": "2.0", "id": 4, "method": "tools/call", "params": {"name": "lab_submit", "arguments": action}},
                                {"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "lab_submit", "arguments": {"operation": "does.not.exist", "arguments": {}, "request_id": "mcp-unknown"}}}]
                mcp_result = subprocess.run([sys.executable, str(ROOT / "scripts/lab_cli.py"), "--url", f"http://127.0.0.1:{port}", "mcp"], input="\n".join(json.dumps(message) for message in mcp_messages) + "\n", env=environment, cwd=ROOT, capture_output=True, text=True, timeout=12)
                mcp = [json.loads(line) for line in mcp_result.stdout.splitlines()]
                check("actual stdio MCP negotiates and lists bounded tools", mcp_result.returncode == 0 and len(mcp) == 5 and mcp[0]["result"]["protocolVersion"] == "2025-11-25" and len(mcp[1]["result"]["tools"]) == 5)
                check("MCP observes same actual game run", mcp[2]["result"]["structuredContent"]["run_id"] == run_id and mcp[2]["result"]["structuredContent"]["state"]["module"]["setting"] is False)
                check("MCP retry shares HTTP and CLI mutation receipt", mcp[3]["result"]["structuredContent"] == applied and mcp[3]["result"]["isError"] is False)
                check("MCP preserves domain failure and excludes credentials", mcp[4]["result"]["isError"] is True and mcp[4]["result"]["structuredContent"]["code"] == "UNKNOWN_OPERATION" and token not in mcp_result.stdout + mcp_result.stderr)
                check("child output contains no credentials or engine errors", token not in log_path.read_text(encoding="utf-8", errors="replace") and "SCRIPT ERROR" not in log_path.read_text(encoding="utf-8", errors="replace"))
            except (RuntimeError, OSError, ValueError, KeyError, ClientError, subprocess.SubprocessError) as error:
                error_code = str(error) if isinstance(error, RuntimeError) else type(error).__name__
            finally:
                stop_child(child)
                child_log = log_path.read_bytes()[-131072:].decode("utf-8", errors="replace").replace(token, "[redacted]")
                artifact_log = ROOT / "artifacts/live-api-child.log"
                artifact_log.parent.mkdir(parents=True, exist_ok=True)
                artifact_log.write_text(child_log, encoding="utf-8")
        default_environment = os.environ.copy()
        default_environment.pop("GODOT_LAB_API_TOKEN", None)
        default_environment.pop("GODOT_LAB_API_PORT", None)
        with log_path.open("wb") as log:
            ordinary = subprocess.Popen(command, cwd=ROOT, env=default_environment, stdout=log, stderr=subprocess.STDOUT, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
            try:
                time.sleep(1)
                no_listener = False
                try:
                    with socket.create_connection(("127.0.0.1", port), timeout=0.5):
                        pass
                except OSError:
                    no_listener = True
                startup_log = log_path.read_text(encoding="utf-8", errors="replace")
                checks.append({"name": "ordinary startup without token has no API listener", "passed": no_listener and ordinary.poll() is None and "SCRIPT ERROR" not in startup_log and "ERROR:" not in startup_log})
            finally:
                stop_child(ordinary)
        # Windows may release inherited redirected file handles after process exit.
        time.sleep(0.2)
    report = {"ok": bool(checks) and not error_code and all(item["passed"] for item in checks), "run_id": run_id, "checks": checks, "error": error_code, "route": "real-loopback-child-host", "limits": ["HTTP plus synchronous stdio MCP prototype; no WebSocket/streaming/jobs claim", "Headless route does not qualify capture or devices"]}
    output = ROOT / args.report
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"ok": report["ok"], "checks": len(checks), "error": error_code}))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
