# Implementation and qualification waves

The 96 contracts define the destination. Coding proceeds ahead of qualification in bounded, independently owned modules. A prototype can become useful before all of its shared-system and profile prerequisites qualify. A/B ticket completion still requires the complete contract and its declared evidence; a passing prototype scenario does not close that ticket.

## First implementation wave

The host now loads a searchable, exported copy of all 96 capability descriptions. It preserves the six original rooms and adds 17 playable system prototypes, twelve graphics/world prototypes and six data/automation prototypes: 41 playable routes in total. Catalog rows identify PLAY, PROTOTYPE and SPECIFIED explicitly. Unimplemented rows explain their intended payoff without launching a substitute mechanism.

| Prototypes | Source | Actual mechanism |
|---|---|---|
| LAB-007 | `game/labs/modules/system_labs.gd` | TileMapLayer atlas, neighbor variants, TileSet collision and a CharacterBody2D courier |
| LAB-012, LAB-013 | Same module | InputMap key/pad dispatch and Control focus/settings/dialogs |
| LAB-014, LAB-018 | Same module | Original branching dialogue and real ResourceSaver/uncached ResourceLoader |
| LAB-037 through LAB-041 | Same module | Installed capability probes, request/revision ledger, hashed fixture staging, owned simulation pause and signal wiring |
| LAB-074, LAB-075, LAB-077 | Same module | Guarded state transitions, objective/reward ordering and inventory proposal/commit/undo |
| LAB-078 through LAB-081 | Same module | TranslationServer fixtures, focus restoration, scoped comfort preferences and pointer/keyboard drag proposals |

The reusable domain is `game/labs/systems/system_domain.gd`. Launch `godot --path game --scene res://labs/systems/extraction.tscn` to use it without the museum host. The host injects services and routes custom controls and automated scenarios through `game/domain/operation_bus.gd`. The inspector shows actual observations, operation descriptors and terminal receipts.

Shared foundations include bounded typed synchronous operation dispatch, idempotent request IDs, stale revision/epoch rejection, ordered simulation-record validation, evidence identity/channel validation, atomic scoped documents, fixture integrity/provenance, job-state transitions and installed capability probes. These are narrower than the full shared-system tickets: a job registry alone is not a worker pool, a record hash is not authentication, and a manifest declaration is not media inspection.

## Test waves

1. Compile the independent modules while code is being authored.
2. Run domain/service tests, actual module scenarios, negative probes, reset/reentry and original-room regression together.
3. Run the optional live transport against a real child process and verify identity, authorization, retries and malformed traffic.
4. Inspect rendered frames and execute the Windows export. Run the same scenarios from the exported artifact.
5. Record selected implemented scenarios through the official Cappy package, decode actual media and validate source/fixture/state identity before making provider/audio claims.

Use `python scripts/check.py` for the current logic wave; `--render --export` also runs all registered prototype scenarios in the renderer and exported executable. Source-only visual tests explicitly distinguish unavailable Dummy-renderer readbacks from actual Compatibility pixel checks. Selected provider captures and composed-journey qualification are recorded separately in [BUILD_STATUS](BUILD_STATUS.md). Physical input, human comfort and other-device acceptance remain deferred.

## Subsequent code waves

Twelve graphics/world exhibits are implemented: LAB-008, LAB-009, LAB-011, LAB-016, LAB-017, LAB-019, LAB-023, LAB-055, LAB-060, LAB-061, LAB-066 and LAB-068. They use real AnimationTree/Player, CPU particles, collision-aware cameras, heightfield meshes/colliders, MultiMesh, shaders, pathfinding, image textures, vertex colors and independent viewports. Their standalone extraction scene is `game/labs/visual/extraction.tscn`.

The next six implementations share `game/labs/modules/data_labs.gd` and small reusable data helpers:

| Prototype | Actual mechanism | Scope |
|---|---|---|
| LAB-025 | Ordered fixture operations, SimulationRecord integrity, disk save/load and isolated replay | Declared script fixture; no general deterministic physics claim |
| LAB-028 | Real WorkerThreadPool task, main-thread result commit, cancellation and join | Bounded integer workload; no GPU/remote worker claim |
| LAB-036 | Warm-up, measured fixed workloads, sample variance and Performance counters | Script workload timings; no FPS or cross-host benchmark claim |
| LAB-089 | Bounded local parameter sweep, cached-row resume and cancellation | At most eight cases; sweep recording remains unqualified |
| LAB-091 | Actual generated image/PCM and semantic dictionary comparison | Declared original fixtures; no automatic golden approval |
| LAB-092 | Repeated actual mesh/resource allocation, bounded cache and releasable retained resources | Observable local lifecycle counters; no full leak-detector claim |

The live HTTP/CLI/stdio MCP adapter is an opt-in local prototype sharing the operation bus. Actual transport tests operate a separately identified child process; this subset does not complete the broader streaming/WebSocket/capture contracts. Modules remain unavailable until registered with real implementations.

Foundation-first code commits and later test waves keep changes reviewable. Source/export validation is the final integration gate; partial qualification is retained explicitly rather than inherited from historical recordings.
