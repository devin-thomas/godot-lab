"""Bounded stdlib client for the explicitly enabled Godot Lab loopback API."""
from __future__ import annotations

import argparse
import http.client
import json
import os
from pathlib import Path
import sys
from typing import Any
import urllib.error
import urllib.parse
import urllib.request
import uuid

MAX_REQUEST_BYTES = 65536
MAX_RESPONSE_BYTES = 262144
SAFE_INTEGER = 9007199254740991
MCP_PROTOCOL = "2025-11-25"


class ClientError(Exception):
    def __init__(self, code: str):
        self.code = code
        super().__init__(code)


class Parser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        raise ClientError("INVALID_ARGUMENT")


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req: Any, fp: Any, code: int, msg: str, headers: Any, newurl: str) -> None:
        raise ClientError("REDIRECT_REFUSED")


def _pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ClientError("DUPLICATE_JSON_KEY")
        result[key] = value
    return result


def _nonfinite(value: str) -> None:
    raise ClientError("NONFINITE_NUMBER")


def parse_json(text: str) -> Any:
    try:
        return json.loads(text, object_pairs_hook=_pairs, parse_constant=_nonfinite)
    except (json.JSONDecodeError, RecursionError) as error:
        raise ClientError("INVALID_JSON") from error


def validate_url(url: str) -> str:
    try:
        parsed = urllib.parse.urlsplit(url)
        port = parsed.port
    except ValueError as error:
        raise ClientError("INVALID_URL") from error
    if (parsed.scheme != "http" or parsed.hostname not in {"127.0.0.1", "localhost"}
            or parsed.username is not None or parsed.password is not None
            or parsed.query or parsed.fragment or parsed.path not in {"", "/"}
            or port is None or not 1 <= port <= 65535):
        raise ClientError("INVALID_URL")
    return url.rstrip("/")


def validate_request(request: Any) -> dict[str, Any]:
    if not isinstance(request, dict) or set(request) - {"operation", "arguments", "request_id", "epoch", "expected_revision"}:
        raise ClientError("INVALID_REQUEST")
    for key in ("operation", "request_id"):
        if not isinstance(request.get(key), str) or not 1 <= len(request[key]) <= 128:
            raise ClientError("INVALID_REQUEST")
    if not isinstance(request.get("arguments"), dict) or len(request["arguments"]) > 32:
        raise ClientError("INVALID_REQUEST")
    for key in ("epoch", "expected_revision"):
        if key in request and (type(request[key]) is not int or not 0 <= request[key] <= SAFE_INTEGER):
            raise ClientError("INVALID_REQUEST")
    try:
        payload = json.dumps(request, allow_nan=False).encode("utf-8")
    except (TypeError, ValueError, RecursionError) as error:
        raise ClientError("INVALID_REQUEST") from error
    if len(payload) > MAX_REQUEST_BYTES:
        raise ClientError("REQUEST_TOO_LARGE")
    return request


def request_api(url: str, path: str, *, token: str = "", payload: dict[str, Any] | None = None,
                timeout: float = 5.0) -> dict[str, Any]:
    url = validate_url(url)
    if not 0 < timeout <= 30:
        raise ClientError("INVALID_TIMEOUT")
    if path != "/health" and not token:
        raise ClientError("TOKEN_REQUIRED")
    if "\r" in token or "\n" in token or len(token) > 512:
        raise ClientError("INVALID_TOKEN")
    headers = {"Accept": "application/json", "Connection": "close"}
    if token:
        headers["Authorization"] = "Bearer " + token
    data = None
    if payload is not None:
        validate_request(payload)
        data = json.dumps(payload, allow_nan=False).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url + path, data=data, headers=headers,
                                     method="POST" if data is not None else "GET")
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    status = 200
    try:
        response = opener.open(request, timeout=timeout)
    except urllib.error.HTTPError as error:
        response = error
        status = error.code
    except (urllib.error.URLError, TimeoutError, OSError) as error:
        raise ClientError("CONNECTION_FAILED") from error
    try:
        with response:
            body = response.read(MAX_RESPONSE_BYTES + 1)
    except (OSError, TimeoutError, http.client.HTTPException) as error:
        raise ClientError("RESPONSE_INTERRUPTED") from error
    if len(body) > MAX_RESPONSE_BYTES:
        raise ClientError("RESPONSE_TOO_LARGE")
    try:
        result = parse_json(body.decode("utf-8"))
    except UnicodeDecodeError as error:
        raise ClientError("INVALID_RESPONSE") from error
    if not isinstance(result, dict) or type(result.get("ok")) is not bool or not isinstance(result.get("code"), str):
        raise ClientError("INVALID_RESPONSE")
    if status >= 400 and result["ok"]:
        raise ClientError("INVALID_RESPONSE")
    if path == "/health" and (result.get("service") != "godot-lab-live" or not isinstance(result.get("run_id"), str) or not result["run_id"]):
        raise ClientError("IDENTITY_MISMATCH")
    return result


def _read_request(path: str) -> dict[str, Any]:
    try:
        if path == "-":
            source = getattr(sys.stdin, "buffer", sys.stdin)
            raw = source.read(MAX_REQUEST_BYTES + 1)
            if isinstance(raw, str):
                raw = raw.encode("utf-8")
        else:
            with Path(path).open("rb") as source:
                raw = source.read(MAX_REQUEST_BYTES + 1)
    except OSError as error:
        raise ClientError("INPUT_UNAVAILABLE") from error
    if len(raw) > MAX_REQUEST_BYTES:
        raise ClientError("REQUEST_TOO_LARGE")
    try:
        return validate_request(parse_json(raw.decode("utf-8")))
    except UnicodeDecodeError as error:
        raise ClientError("INVALID_JSON") from error


def parser() -> Parser:
    result = Parser(description=__doc__)
    result.add_argument("--url", default=os.environ.get("GODOT_LAB_API_URL", "http://127.0.0.1:8765"))
    result.add_argument("--timeout", type=float, default=5.0)
    commands = result.add_subparsers(dest="command", required=True, parser_class=Parser)
    for name in ("health", "operations", "state"):
        commands.add_parser(name)
    commands.add_parser("mcp", help="Serve the same bounded API tools over MCP stdio")
    events = commands.add_parser("events")
    events.add_argument("--after", type=int, default=0)
    submit = commands.add_parser("submit")
    submit.add_argument("--file", help="Request JSON file, or - for stdin")
    submit.add_argument("--operation")
    submit.add_argument("--arguments", default="{}", help="Typed argument JSON object")
    submit.add_argument("--request-id")
    submit.add_argument("--expected-revision", type=int)
    submit.add_argument("--epoch", type=int)
    return result


def mcp_tools() -> list[dict[str, Any]]:
    empty = {"type": "object", "properties": {}, "additionalProperties": False}
    tools = [{"name": name, "description": description, "inputSchema": empty,
              "annotations": {"readOnlyHint": True, "openWorldHint": False}}
             for name, description in (("lab_health", "Identify the explicitly enabled local game session."),
                                       ("lab_operations", "Describe the session's registered typed operations."),
                                       ("lab_state", "Observe the actual game session."))]
    tools.append({"name": "lab_events", "description": "Read bounded events after a cursor; expired history fails explicitly.",
                  "inputSchema": {"type": "object", "properties": {"after": {"type": "integer", "minimum": 0, "maximum": SAFE_INTEGER}}, "additionalProperties": False},
                  "annotations": {"readOnlyHint": True, "openWorldHint": False}})
    tools.append({"name": "lab_submit", "description": "Submit one typed game operation; preserve request_id for retries.",
                  "inputSchema": {"type": "object", "properties": {
                      "operation": {"type": "string", "minLength": 1, "maxLength": 128},
                      "request_id": {"type": "string", "minLength": 1, "maxLength": 128},
                      "arguments": {"type": "object", "maxProperties": 32},
                      "epoch": {"type": "integer", "minimum": 0, "maximum": SAFE_INTEGER},
                      "expected_revision": {"type": "integer", "minimum": 0, "maximum": SAFE_INTEGER}},
                      "required": ["operation", "arguments", "request_id"], "additionalProperties": False},
                  "annotations": {"readOnlyHint": False, "destructiveHint": True, "openWorldHint": False}})
    return tools


def _mcp_call(url: str, token: str, timeout: float, name: str, arguments: Any) -> dict[str, Any]:
    if not isinstance(arguments, dict):
        raise ClientError("INVALID_ARGUMENT")
    payload = None
    if name == "lab_submit":
        payload = validate_request(arguments)
        path = "/v1/operations"
    elif name == "lab_events":
        after = arguments.get("after", 0)
        if set(arguments) - {"after"} or type(after) is not int or not 0 <= after <= SAFE_INTEGER:
            raise ClientError("INVALID_CURSOR")
        path = "/v1/events?after=" + str(after)
    else:
        if arguments:
            raise ClientError("INVALID_ARGUMENT")
        path = {"lab_health": "/health", "lab_operations": "/v1/operations", "lab_state": "/v1/state"}[name]
    return request_api(url, path, token=token, payload=payload, timeout=timeout)


def serve_mcp(url: str, token: str, timeout: float) -> int:
    """Synchronous tools only: newline JSON-RPC, no arbitrary code or file access."""
    initialized = False
    negotiated = False
    source = getattr(sys.stdin, "buffer", sys.stdin)
    for _index in range(4096):
        line = source.readline(MAX_REQUEST_BYTES + 1)
        if not line:
            return 0
        if isinstance(line, str):
            line = line.encode("utf-8")
        response: dict[str, Any]
        identifier = None
        try:
            if len(line) > MAX_REQUEST_BYTES:
                raise ClientError("REQUEST_TOO_LARGE")
            message = parse_json(line.decode("utf-8"))
            if not isinstance(message, dict) or message.get("jsonrpc") != "2.0" or not isinstance(message.get("method"), str):
                raise ClientError("INVALID_REQUEST")
            identifier = message.get("id")
            has_id = "id" in message
            if has_id and not ((type(identifier) is int and abs(identifier) <= SAFE_INTEGER) or (isinstance(identifier, str) and 1 <= len(identifier) <= 128)):
                raise ClientError("INVALID_REQUEST")
            method = message["method"]
            params = message.get("params", {})
            if not isinstance(params, dict):
                raise ClientError("INVALID_ARGUMENT")
            if not has_id:
                if method == "notifications/initialized" and negotiated:
                    initialized = True
                continue
            if method == "initialize":
                if negotiated or not isinstance(params.get("protocolVersion"), str) or not isinstance(params.get("capabilities"), dict) or not isinstance(params.get("clientInfo"), dict):
                    raise ClientError("INVALID_INITIALIZATION")
                negotiated = True
                result = {"protocolVersion": MCP_PROTOCOL, "capabilities": {"tools": {"listChanged": False}},
                          "serverInfo": {"name": "godot-lab-loopback", "version": "1.0.0"}}
            elif method == "ping":
                result = {}
            elif not initialized:
                raise ClientError("NOT_INITIALIZED")
            elif method == "tools/list":
                if params:
                    raise ClientError("INVALID_ARGUMENT")
                result = {"tools": mcp_tools()}
            elif method == "tools/call":
                name = params.get("name")
                if not isinstance(name, str) or name not in {tool["name"] for tool in mcp_tools()} or set(params) - {"name", "arguments", "_meta"}:
                    raise ClientError("UNKNOWN_TOOL")
                try:
                    value = _mcp_call(url, token, timeout, name, params.get("arguments", {}))
                except ClientError as error:
                    value = {"ok": False, "code": error.code}
                result = {"content": [{"type": "text", "text": json.dumps(value, allow_nan=False)}],
                          "structuredContent": value, "isError": not value["ok"]}
            else:
                response = {"jsonrpc": "2.0", "id": identifier, "error": {"code": -32601, "message": "METHOD_NOT_FOUND"}}
                print(json.dumps(response), flush=True)
                continue
            response = {"jsonrpc": "2.0", "id": identifier, "result": result}
        except (ClientError, UnicodeDecodeError) as error:
            code = error.code if isinstance(error, ClientError) else "INVALID_UTF8"
            response = {"jsonrpc": "2.0", "id": identifier, "error": {"code": -32700 if code in {"INVALID_JSON", "INVALID_UTF8", "DUPLICATE_JSON_KEY"} else -32602, "message": code}}
        print(json.dumps(response, allow_nan=False), flush=True)
        if len(line) > MAX_REQUEST_BYTES:
            return 1
    print(json.dumps({"jsonrpc": "2.0", "id": None, "error": {"code": -32000, "message": "BUDGET_EXCEEDED"}}), flush=True)
    return 1


def main(argv: list[str] | None = None) -> int:
    try:
        args = parser().parse_args(argv)
        token = os.environ.get("GODOT_LAB_API_TOKEN", "")
        if args.command == "mcp":
            return serve_mcp(validate_url(args.url), token, args.timeout)
        payload = None
        if args.command == "submit":
            if args.file:
                if args.operation or args.request_id or args.expected_revision is not None or args.epoch is not None or args.arguments != "{}":
                    raise ClientError("AMBIGUOUS_INPUT")
                payload = _read_request(args.file)
            elif args.operation:
                payload = {"operation": args.operation, "arguments": parse_json(args.arguments),
                           "request_id": args.request_id or str(uuid.uuid4())}
                for option in ("epoch", "expected_revision"):
                    if getattr(args, option) is not None:
                        payload[option] = getattr(args, option)
                validate_request(payload)
            else:
                payload = _read_request("-")
            path = "/v1/operations"
        elif args.command == "events":
            if not 0 <= args.after <= SAFE_INTEGER:
                raise ClientError("INVALID_CURSOR")
            path = "/v1/events?after=" + str(args.after)
        else:
            path = "/health" if args.command == "health" else "/v1/" + args.command
        result = request_api(args.url, path, token=token, payload=payload, timeout=args.timeout)
        print(json.dumps(result, allow_nan=False))
        return 0 if result["ok"] else 1
    except ClientError as error:
        print(json.dumps({"ok": False, "code": error.code}))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
