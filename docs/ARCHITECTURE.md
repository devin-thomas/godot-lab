# Architecture: bootstrap and expanded host

The host preserves the six original rooms and now registers separate system and visual modules. `game/labs/lab_registry.gd` owns availability, the exported 96-contract catalog and module construction. `game/domain/operation_bus.gd` validates requests and emits terminal receipts/events; controls, scenarios, the optional HTTP listener and CLI/MCP client share it. [Implementation waves](IMPLEMENTATION_WAVES.md) lists actual source boundaries and their narrower scope. Remaining boundaries below are target architecture, and [BUILD_STATUS](BUILD_STATUS.md) distinguishes current evidence.

## Dependency direction

Player UI / scenario / CLI / live API / MCP -> validation/dispatcher -> lab/domain component -> receipts/events -> inspector / recorder / analysis.

The host owns navigation, fixture selection, injected services, input context, progress and settings. Modules own their scenes/transient state. Components contain extractable mechanisms. Adapters own renderer/platform/provider/editor/native integration. Evidence tools consume records/artifacts without becoming ordinary play dependencies.

Focused scenes with injected context follow [Godot scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html). Extraction requires a tested minimal scene.

| Planned area | Responsibility | Excluded responsibility |
|---|---|---|
| game/host/ | Catalog, world, inspector, settings, journeys, input | Every lab simulation |
| game/domain/ | Schemas, IDs, revisions, receipts/events, jobs, profiles | UI nodes and OBS |
| game/labs/<id>/ | Module, scenes, fixture adapter, reset, scenarios | Sibling internals |
| game/components/ | Reusable movement/animation/audio/world/documents | Private fixtures |
| game/adapters/ | Optional platform/renderer/native/network/Cappy | Shortcut progress mutation |
| game/fixtures/ | Original small sources/manifests | User files and capture caches |
| game/tests/ | Operation/lifecycle/fixture checks | Expected-state assignment as proof |
| scripts/ | Build, capture, analysis, authoring orchestration | Ordinary play requirement |
| planning/ | Machine-readable specified program | Implied runtime registration |

The first migration keeps original controls/scenarios/seals/saves compatible and extracts new mechanisms into lab modules and reusable domains. Original-room simulation still lives in the bootstrap host/world; those deeper extraction tickets remain open.

## Module lifecycle

Static registration -> profile probe -> fixture validation -> isolated namespace -> instantiate -> inject/connect -> ready -> operations/events -> reset/exit -> cancel jobs -> disconnect signals/peers -> stop audio -> release nodes/resources -> cleanup receipt.

Reset owns transient scene/demo state, not unrelated progress. Requests during teardown receive a lifecycle error. Entering a room does not start recording, open external listeners, load native binaries or overwrite an export.

## Simulation and presentation

Stable actor/event IDs survive visual substitution. Fixed-tick queues and sequence ordering drive simulation. Presentation interpolates visible actors, effects and camera tracks. Capture selects a viewer camera independently of the player. Simulation time, presentation time and wall time are recorded separately; physics tolerances and renderer-dependent output are declared.

## Optional adapters and storage

CoreLocal is default. RenderAdvanced, NetworkLocal, ProductionTools, EditorNative, Web, Mobile and XR have independently probed readiness/fallbacks. Default import/export cannot require OBS, Blender, MCP, a native compiler, mobile SDKs or XR hardware. Renderer claims need separate evidence: [renderer overview](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html); export selection needs installed probes: [feature tags](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html).

Progress, experiment documents, records, captures and worker checkpoints have separate schemas/namespaces. Existing schema-1 seals remain supported. Migrations stage/validate before publication; replay is history rather than a general save. Video is an artifact rather than simulation truth.

## Public/private boundary

Public modules and original fixtures work alone. Private missions consume qualified public components at an exact revision and own restricted recipes/provenance/namespaces. Neither imports an uncommitted sibling checkout. Public archive and private pin gates verify these boundaries.
