"""Client failure semantics and request boundary checks, without a Godot listener."""
from __future__ import annotations

from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts import lab_cli


class ClientTests(unittest.TestCase):
    def test_loopback_only_and_no_url_credentials(self) -> None:
        for url in ("https://127.0.0.1:8000", "http://example.com:8000", "http://token@127.0.0.1:8000", "http://127.0.0.1:8000/path", "http://127.0.0.1:8000?token=private", "http://127.0.0.1:0"):
            with self.subTest(url=url), self.assertRaises(lab_cli.ClientError):
                lab_cli.validate_url(url)
        self.assertEqual(lab_cli.validate_url("http://127.0.0.1:8000/"), "http://127.0.0.1:8000")

    def test_duplicate_json_keys_and_nonfinite_numbers_fail(self) -> None:
        for source in ('{"operation":"a","operation":"b"}', '{"arguments":{"x":1,"x":2}}', '{"x":NaN}', '{"x":Infinity}'):
            with self.subTest(source=source), self.assertRaises(lab_cli.ClientError):
                lab_cli.parse_json(source)

    def test_revision_cannot_be_boolean_negative_or_string(self) -> None:
        request = {"operation": "host.enter", "arguments": {"id": "LAB-013"}, "request_id": "test"}
        for revision in (True, -1, "1", 1.2):
            with self.subTest(revision=revision), self.assertRaises(lab_cli.ClientError):
                lab_cli.validate_request({**request, "expected_revision": revision})

    def test_submit_stdin_and_retry_id_preserved(self) -> None:
        request = {"operation": "host.enter", "arguments": {"id": "LAB-013"}, "request_id": "same-logical-request"}
        output = io.StringIO()
        with patch.dict(os.environ, {"GODOT_LAB_API_TOKEN": "private-token"}), patch("sys.stdin", io.StringIO(json.dumps(request))), patch.object(lab_cli, "request_api", return_value={"ok": True, "code": "ENTERED"}) as call, redirect_stdout(output):
            code = lab_cli.main(["submit", "--file", "-"])
        self.assertEqual(code, 0)
        self.assertEqual(call.call_args.kwargs["payload"], request)
        self.assertNotIn("private-token", output.getvalue())

    def test_server_rejection_is_nonzero_and_preserved(self) -> None:
        output = io.StringIO()
        with patch.object(lab_cli, "request_api", return_value={"ok": False, "code": "REVISION_CONFLICT"}), redirect_stdout(output):
            code = lab_cli.main(["state"])
        self.assertEqual(code, 1)
        self.assertEqual(json.loads(output.getvalue())["code"], "REVISION_CONFLICT")

    def test_missing_token_does_not_attempt_connection(self) -> None:
        with self.assertRaises(lab_cli.ClientError) as failure:
            lab_cli.request_api("http://127.0.0.1:8000", "/v1/state")
        self.assertEqual(failure.exception.code, "TOKEN_REQUIRED")

    def test_argument_failure_is_structured(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            code = lab_cli.main(["invalid-command"])
        self.assertEqual(code, 1)
        self.assertEqual(json.loads(output.getvalue()), {"ok": False, "code": "INVALID_ARGUMENT"})

    def test_ambiguous_request_sources_refused(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            code = lab_cli.main(["submit", "--file", "-", "--operation", "host.hub"])
        self.assertEqual(code, 1)
        self.assertEqual(json.loads(output.getvalue())["code"], "AMBIGUOUS_INPUT")

    def test_health_rejects_another_service(self) -> None:
        response = io.BytesIO(b'{"ok":true,"code":"OK","service":"other","run_id":"run"}')
        with patch.object(lab_cli.urllib.request, "build_opener") as opener, self.assertRaises(lab_cli.ClientError) as failure:
            opener.return_value.open.return_value = response
            lab_cli.request_api("http://127.0.0.1:8000", "/health")
        self.assertEqual(failure.exception.code, "IDENTITY_MISMATCH")

    def test_interrupted_response_has_structured_failure(self) -> None:
        with patch.object(lab_cli.urllib.request, "build_opener") as opener, self.assertRaises(lab_cli.ClientError) as failure:
            response = opener.return_value.open.return_value
            response.__enter__.return_value = response
            response.read.side_effect = ConnectionResetError()
            lab_cli.request_api("http://127.0.0.1:8000", "/health")
        self.assertEqual(failure.exception.code, "RESPONSE_INTERRUPTED")

    def test_mcp_requires_initialize_and_rejects_unknown_tool(self) -> None:
        messages = [{"jsonrpc": "2.0", "id": 1, "method": "tools/list"},
                    {"jsonrpc": "2.0", "id": 2, "method": "initialize", "params": {"protocolVersion": lab_cli.MCP_PROTOCOL, "capabilities": {}, "clientInfo": {"name": "test", "version": "1"}}},
                    {"jsonrpc": "2.0", "method": "notifications/initialized"},
                    {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": {"invalid": True}}}]
        source = io.StringIO("\n".join(json.dumps(message) for message in messages) + "\n")
        output = io.StringIO()
        with patch("sys.stdin", source), redirect_stdout(output):
            code = lab_cli.serve_mcp("http://127.0.0.1:8000", "token", 1)
        results = [json.loads(line) for line in output.getvalue().splitlines()]
        self.assertEqual(code, 0)
        self.assertEqual(results[0]["error"]["message"], "NOT_INITIALIZED")
        self.assertEqual(results[1]["result"]["protocolVersion"], lab_cli.MCP_PROTOCOL)
        self.assertEqual(results[2]["error"]["message"], "UNKNOWN_TOOL")

    def test_mcp_preserves_shared_domain_failure(self) -> None:
        messages = [{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": lab_cli.MCP_PROTOCOL, "capabilities": {}, "clientInfo": {"name": "test", "version": "1"}}},
                    {"jsonrpc": "2.0", "method": "notifications/initialized"},
                    {"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "lab_submit", "arguments": {"operation": "unknown", "arguments": {}, "request_id": "test"}}}]
        output = io.StringIO()
        with patch("sys.stdin", io.StringIO("\n".join(json.dumps(message) for message in messages) + "\n")), patch.object(lab_cli, "request_api", return_value={"ok": False, "code": "UNKNOWN_OPERATION"}), redirect_stdout(output):
            lab_cli.serve_mcp("http://127.0.0.1:8000", "token", 1)
        result = json.loads(output.getvalue().splitlines()[-1])["result"]
        self.assertTrue(result["isError"])
        self.assertEqual(result["structuredContent"]["code"], "UNKNOWN_OPERATION")


if __name__ == "__main__":
    unittest.main()
