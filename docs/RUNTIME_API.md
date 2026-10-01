# Actual runtime operation API

The current adapter is an optional authenticated **loopback HTTP** listener with a Python stdlib CLI and MCP stdio bridge. It dispatches synchronously through the same OperationBus used by prototype controls/scenarios. This narrower implementation does not complete the WebSocket subscription, asynchronous job, remote-machine or general session contracts.

## Enable explicitly

Ordinary startup opens no listener. Set `GODOT_LAB_API_PORT` (0 asks the OS for an unused port) and `GODOT_LAB_API_TOKEN` in the game's environment. Empty tokens, malformed ports and bind failures reject startup. The nonsecret `LIVE_API` startup JSON reports `bound_port`, random `run_id` and `service: godot-lab-live`; match that run identity before driving the host. Tokens are never command-line arguments or receipts.

The CLI takes `--url http://127.0.0.1:<port>` or `GODOT_LAB_API_URL` and reads its token from `GODOT_LAB_API_TOKEN`. It refuses redirects, non-loopback URLs, oversized payloads and invalid/nonfinite JSON. Examples after the environment is configured:

```powershell
python scripts/lab_cli.py --url http://127.0.0.1:8765 health
python scripts/lab_cli.py --url http://127.0.0.1:8765 operations
python scripts/lab_cli.py --url http://127.0.0.1:8765 state
python scripts/lab_cli.py --url http://127.0.0.1:8765 submit --operation host.enter --arguments '{"id":"LAB-013"}' --request-id enter-ui-1
python scripts/lab_cli.py --url http://127.0.0.1:8765 submit --operation ui.set_setting --arguments '{"enabled":true}' --request-id setting-1
python scripts/lab_cli.py --url http://127.0.0.1:8765 events --after 0
python scripts/lab_cli.py --url http://127.0.0.1:8765 mcp
```

8765 is an example; use the actual startup port. A submission also accepts `--file request.json` or `--file -` for stdin. Non-success responses preserve their code and exit nonzero. MCP protocol 2025-11-25 exposes `lab_health`, `lab_operations`, `lab_state`, `lab_events` and `lab_submit`; domain errors remain errors rather than success-shaped text.

## HTTP routes

| Route | Authorization | Result |
|---|---|---|
| GET `/health` | None | Nonsecret process identity/protocol |
| GET `/v1/operations` | Bearer | Actual active typed descriptors |
| GET `/v1/state` | Bearer | Bounded semantic host/module observations |
| GET `/v1/events?after=N` | Bearer | Bounded ordered mutation events or expired-cursor error |
| POST `/v1/operations` | Bearer | Synchronous terminal bus receipt |

Request shape: `{operation, arguments, request_id, expected_revision?, epoch?}`. Descriptors declare bounded argument rules; unknown arguments and operations reject before dispatch. A same-ID identical retry returns the original terminal receipt. Changed payload with the same ID rejects. Reset/entry invalidates epoch history; revisions and event cursors remain monotonic. UI reset and return use the same host operations. Only the active module's vocabulary is registered; discover again after changing rooms.

The server admits at most eight clients, 8 KiB headers, 64 KiB bodies, 256 KiB responses and a five-second client deadline. It rejects ambiguous/repeated headers, chunked transfer, duplicate JSON keys, invalid UTF-8 and traversal-shaped paths. Observer results omit historical receipts to prevent recursively growing snapshots.

## Verify

```powershell
python tests/live_api_gate.py
python -m unittest discover -s tests -p test_lab_cli.py
```

The transport gate starts its own real game child, matches startup/health run IDs, checks rejected traffic, drives actual module state, retries requests through HTTP/CLI/MCP and checks default startup without a listener. These checks establish local transport/semantic parity. They do not establish capture, remote transport, accessibility, physical devices or human comfort.
