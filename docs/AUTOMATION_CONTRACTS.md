# Proposed automation contracts

Design revision 1, 2026-10-01. **These contracts are proposed and are not a description of an implemented network protocol.** The current game has six Cappy scenarios, a bounded automatic input replay payload, semantic events and local assertion reports. It does not yet implement this general operation registry, CLI, MCP server or live API. The released Cappy adapter protocol remains an upstream contract; these types sit in the game's domain and entry adapters.

## Identity and compatibility

Use distinct stable IDs for lab, operation, scenario, fixture, entity, run, request, receipt and artifact. Public lab catalog IDs follow the [extension contract](EXTENSION_CONTRACT.md); current Cappy scenario slugs remain `motion`, `physics`, `navigation`, `materials`, `audio`, and `persistence`. Do not rename them just to introduce a general registry. Retired IDs remain reserved.

`schemaVersion` is an integer. Unknown major schema/protocol versions fail before mutation. Optional forward-compatible metadata belongs in a bounded `extras` map and survives round trips; it cannot become executable arguments. Required fields, duplicate JSON keys, invalid UTF-8, non-finite numbers and unknown executable argument fields fail validation. Never silently coerce strings to numbers or clamp values to make them succeed.

| Contract | Required identity and fields | Validation |
|---|---|---|
| LabDescriptor | `labId`, `slug`, `version`, title, mechanism, operations, scenarios, capability gates, implementation/evidence state | IDs unique; advertised operation/scenario exists; proposed labs remain visibly proposed |
| OperationDescriptor | `operationId`, version, effect kind, argument schema, result schema, required capabilities, allowed run modes | Typed bounds/defaults/enums documented; destructive scope and cancellation declared |
| ScenarioDescriptor | `scenarioId`, version, lab, fixture, parameter schema, duration, observations, resource budget | Resolved defaults frozen before prepare; original fixture provenance available |
| RunContext | Run ID/epoch, namespace, source fingerprint, engine/renderer, seed, fixture, resolved parameters, clock/presentation profile, limits | Exact actual tool/profile identifiers; no tokens or absolute private paths |
| Receipt | Request/run IDs, outcome, accepted sequence, applied tick when applicable, revision, result/error | Acceptance is not application; a failed operation has no success-shaped result |
| ArtifactDescriptor | Artifact ID, relative path, role, SHA-256, byte count, producer/version, run/capture ID | Path stays within bundle; inspected bytes match hash and producer claim |

## Typed operation vocabulary

Use family/verb names and explicit units. An initial proposed registry includes `lab.enter`, `lab.reset`, `lab.exit`, `motion.jump`, `physics.impulse`, `navigation.target`, `material.select`, `audio.listener.move`, `progress.checkpoint`, and read-only `state.get`/`operations.describe`. Names are design examples, not callable commands today. Future labs add operations through the same registry; entrypoints cannot carry private bypasses.

Argument primitives are bounded string, boolean, finite float, safe integer, enum, stable entity reference, `Vector2`/`Vector3` with named components, and small typed lists/records. Record units (`meters`, `seconds`, `newtonSeconds`) in schemas. Avoid an untyped generic `args` bag: dispatch first resolves the descriptor, then validates its exact record shape. Domain validation also checks entity existence, lab state, capability and resource budget at application time.

Cappy 0.1.0 scenario parameters expose scalar string/number/integer/boolean schemas. Domain vectors or records need an explicit scalar projection, such as an enum referencing a versioned target preset, or separate bounded components. Describe that projection and validate it through the domain schema. Do not pretend the released scalar interface accepts arbitrary JSON or silently skip an incompatible scenario.

Player input routes to the same operation implementation. Continuous movement can use a bounded held-input operation with explicit duration/axis state; replay logs its applied changes rather than browser/keyboard event timestamps. UI presentation choices such as camera/UI visibility are classified separately from gameplay operations.

## Request, queue and receipt

An illustrative request for the proposed protocol:

```json
{
  "schemaVersion": 1,
  "requestId": "req-example-001",
  "runId": "run-example",
  "epoch": 3,
  "kind": "operation",
  "operationId": "physics.impulse",
  "operationVersion": 1,
  "expectedRevision": 12,
  "arguments": {
    "entityId": "fixture-crate",
    "impulseNewtonSeconds": {"x": 2.0, "y": 1.0, "z": 0.0}
  }
}
```

Transport authentication determines the actor/scope; clients cannot grant themselves capabilities inside a request. Validate size/schema/version/run/epoch/scope before queueing. Assign an acceptance sequence and return a queued receipt. Revalidate revision/entity/state/budget when applying at the next eligible simulation tick. A queue acknowledgment must not imply the impulse has happened.

Proposed order: replay applies its recorded tick/sequence exactly; otherwise queued player/live/scenario operations apply at tick start in one assigned sequence order. Record the resolved source and origin for diagnostics, without separate origin-specific mutation implementations. Cancellation and run-end boundaries reject later mutation. Read-only queries return a snapshot with tick/revision and do not change sequence, RNG streams or gameplay state.

Within one run epoch, request ID plus canonical resolved payload identifies a retry. Same ID/same payload returns its existing queued or terminal receipt without repeating effects. Same ID/different payload fails `REQUEST_ID_REUSED`. Check `expectedRevision` at commit and fail `REVISION_CONFLICT` without mutation. Keep the deduplication ledger for the bounded epoch; when it reaches its declared limit, refuse additional distinct requests instead of silently forgetting IDs. Reset increments epoch and invalidates old in-flight requests. This is bounded idempotency, not a permanent cross-process exactly-once promise.

Application returns either a terminal receipt with actual tick/revision/result, or a typed asynchronous job ID. Jobs expose phase/progress/cancel state and eventually one terminal result. Do not hide a job failure after an initial successful queue receipt. A multi-effect domain operation validates before mutation and commits its declared atomic boundary; partial external effects need an explicit partial-failure record.

## Proposed local live transport

Use a versioned WebSocket service on an ephemeral `127.0.0.1` port, disabled unless explicitly launched. Generate a fresh cryptographic token per launch; keep it in a restricted ignored endpoint descriptor with process/run identity. Authenticate in the first bounded frame, not a URL query or public command argument. Authenticate before serving descriptions, screenshots or events. Expire launch credentials on exit and reject stale descriptors/process identities.

A hello response identifies protocol/version/run/epoch and permitted capabilities without echoing the token. Request kinds are operation, query, session and subscription; each has its own typed schema. Correlate replies by request ID. Start with the limits in [AUTOMATION](AUTOMATION.md): eight clients, 64 KiB frames and 256 queued requests, then qualify them. Rate-limit connections, pending queries and screenshot production independently. Bound authentication timeout and idle clients.

Subscriptions use monotonically increasing event sequences and a bounded ring buffer. Reconnect requests a cursor; if older events are gone, report `CURSOR_EXPIRED` and provide a fresh snapshot. Do not invent missing history. Backpressure disconnects or refuses a slow consumer without blocking the simulation. Screenshot queries are explicit, bounded and presentation-only; they return a scoped artifact descriptor, not arbitrary filesystem access.

CLI and MCP share one client implementation and schema validator. Proposed tools: list labs/scenarios, describe operations, start/stop a developer run, apply operation, read state, read bounded events and request evidence screenshot. A tool cannot execute arbitrary GDScript, shell commands or file paths. Cancellation propagates to the same domain job/run. A CLI operation reports structured error plus nonzero exit; MCP reports the same error identity.

The Cappy adapter's authenticated loopback connection remains separate. Both transports refer to the same RunContext and world. Test Cappy freeform record plus live command plus query plus replay before claiming coexistence. Never substitute a separate headless run for the recorded visible game.

## Replay payload and clock contract

The proposed `godot-lab-operations-v1` payload contains header context, bounded applied operations, terminal tick and expected semantic result. This is a future format name; current payloads remain accepted under their actual existing format until a deliberate versioned migration. Each applied record has `tick`, `sequence`, operation ID/version and fully resolved arguments. Seed/fixture/schema/source profiles are validated before constructing the replay world. Refuse unsupported history, unordered/negative ticks, duplicate sequences, unknown operations, oversized record counts and missing dependencies.

Record only applied domain operations in the executable log. Store rejected requests separately for diagnostics. Replay cannot reproduce authentication tokens, provider controls or machine paths. View/camera pose tracks have their own version, coordinate convention and sampling clock; replaying them must leave domain operations/events/state hashes unchanged.

Simulation time is derived from integer ticks and the declared simulation rate. Presentation time depends on the qualified scale/output profile; capture time additionally includes provider/adapter start offset. Keep those fields named distinctly. With the released addon, emit simulation milliseconds once and let its presentation mapping handle scale. Analyzer windows based on Cappy timeline events already include the adapter's master offset; do not add it again. Prove alignment with a known visible/audible cue near start and later in the run.

Current foundation deterministic capability is false. A future adapter may declare deterministic replay only after same-host/build repeated state-hash gates and negative controls pass, with the supported scope recorded. Renderer equality and cross-host equality remain independent claims. A changed simulation rate is a different profile, not automatically equivalent physics.

## Run and evidence bundle

Proposed bundle structure:

```text
run.json                 # identity, context, terminal result and budgets
operations.jsonl         # header plus applied tick/sequence operations
receipts.jsonl           # bounded accepted/applied/rejected requests
events.jsonl             # semantic simulation events and sequence
observations.json        # named assertions, values and tolerances
state.jsonl              # optional per-tick canonical digest
presentation.jsonl       # optional camera/view track, no game mutations
artifacts.json           # relative paths, roles, hashes and producers
analysis.json            # analyzer versions, metrics and failing regions
logs/                    # bounded diagnostics, redacted before publication
```

This is proposed output, not today's file layout. Link actual Cappy session/capture IDs, manifest/master hashes and timeline exports rather than replacing upstream manifests. Each claim names its proof level, prerequisites, observed result and missing gates. A raw recording with no state report proves only the captured pixels/audio; a state report with no provider master proves no OBS capture.

SourceFingerprint includes repository revision, dirty-source status and a hash of the source/input allowlist used for the run. Hashes exclude tokens, caches and nondistributable raw media. Fixture/asset/generator hashes and licenses are explicit. Record actual engine build, renderer/backend, OS, Cappy/Node/OBS/FFmpeg versions and analyzer configuration. Public summaries use generic host profiles and relative paths; private records retain full scheduling identity.

## Failure and cancellation

Proposed errors include `INVALID_REQUEST`, `UNSUPPORTED_SCHEMA`, `UNKNOWN_OPERATION`, `INVALID_ARGUMENT`, `UNAUTHORIZED`, `RUN_MISMATCH`, `STALE_EPOCH`, `REQUEST_ID_REUSED`, `REVISION_CONFLICT`, `QUEUE_FULL`, `BUDGET_EXCEEDED`, `CAPABILITY_UNAVAILABLE`, `ASSERTION_FAILED`, `PROVIDER_FAILED`, `ANALYSIS_FAILED`, `TIMED_OUT`, and `CANCELLED`. Preserve upstream Cappy error codes as provider details; do not rename an unavailable dependency into a passed lab.

Terminal runs are succeeded, failed or cancelled; unavailable and pending describe capability/evidence gates that did not run. One run emits exactly one terminal record. Cancellation is repeatable, refuses later mutations, stops only owned provider work, writes partial-artifact identities and releases the room. An external wall watchdog bounds unresponsive engine/provider cleanup. Hard termination may leave a recoverable incomplete bundle, never an invented success.

## Contract qualification

Before promotion, test schema boundary/duplicate/unknown fields; same-ID retries and mismatched payloads; revision conflict at application; stale epoch; unauthorized/slow/oversized clients; read-only state invariance; queue saturation; cancel during prepare/run/export; fresh-process replay; wrong fixture/source/schema; shifted action tick; mismatched expected result; missing renderer/provider; wrong capture source; unresolved anchors; disk/output budget exhaustion; and repeated room entry/reset/exit. A deliberately disabled mechanism and a deliberately broken analyzer input must cause the relevant gate to fail.
