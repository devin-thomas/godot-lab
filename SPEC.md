# Godot Lab product specification

Expanded program: 2026-10-01. **96 lab contracts, 16 wings, six delivery milestones, and two independently useful repositories.** This is the product plan; [BUILD_STATUS](docs/BUILD_STATUS.md) remains the authority for implemented behavior. Six baseline rooms have automatic proof, and [implementation waves](docs/IMPLEMENTATION_WAVES.md) records additional playable prototypes. Full A/B contracts remain open for the other 90 labs and the deeper contracts for those six.

## 1. Purpose and audiences

Make Godot's breadth discoverable through a playable executable, living source documentation, and inspectable automation. A player encounters a remarkable effect, changes it, understands the mechanism, and can replay what happened. A developer extracts a small reusable component. An automation builder controls that same system, captures it with the official Cappy package, and inspects source-bound evidence.

The ambition covers engine systems, game authoring, tooling, platform adapters, and the work that agents can automate around them. Six mechanism demos established a bootstrap; they do not fulfill this ambition. The expanded plan takes the Apple Native Lab model of detailed interactions, reusable domain operations, capability probes, fixtures, honest fallbacks, and dependency-ordered qualification. It also includes live authoring, simulation records, scripted asset creation, presentation tracks, combat and animation, and production capture workflows.

## 2. Product shape

An original retro observatory houses sixteen wings. Physical exhibits connect to searchable catalogs, guided journeys, and a compact inspector showing controls, parameters, current state, operation receipts, reset scope, and verified capabilities. Players can inspect a system without turning every room into a text wall. Demonstration cameras and automation controls remain secondary to ordinary play.

The sixteen wings are core, motion, simulation, world, art, rendering, audio, narrative, interfaces, networking, automation, tooling, performance, interchange, platforms, and XR. [The catalog](experiments/INDEX.md) assigns every lab its interaction and proof contract. [The capability matrix](docs/CAPABILITY_MATRIX.md) makes breadth, dependencies, and evidence visible. Ninety-six is a governed starting program, not a claim that every engine API is covered.

The host has a world route, catalog route, fixture browser, session inspector, settings, source/component links, evidence browser, and journey progress. A missing adapter appears with its actual reason and a useful supported fixture path where possible. A replay is labeled as a replay. Future labs are searchable specifications, never active portals or earned completion badges before implementation.

## 3. Requirements

| ID | Requirement | Acceptance anchor |
|---|---|---|
| R-01 | Public core runs independently without accounts | Clean public archive, network-blocked fixture route, no sibling dependency |
| R-02 | Ordinary play is the primary deliverable | Reach, operate, inspect, reset, and exit every enabled lab in an executable |
| R-03 | Entry points share typed operations | UI, scenario, CLI, live API and MCP produce equivalent semantic receipts |
| R-04 | A lab demonstrates depth | Parameter variation, meaningful failure, visible consequence, reusable source and reset |
| R-05 | Readiness is probed | Engine/build, renderer, OS, extension, provider, assets and device reported separately |
| R-06 | Fixtures are original, bounded and isolated | Seed/hash manifest, demo namespace, hostile-input tests and scoped cleanup |
| R-07 | Reset is a lifecycle contract | Jobs, actors, audio, signals, peers and fixtures released without losing ordinary progress |
| R-08 | Live control and Cappy coexist | One session accepts authenticated operations while recording actual game output |
| R-09 | Simulation and presentation are distinct | Fixed-tick ordering, timeline events, independent viewer camera and declared replay tolerance |
| R-10 | Evidence binds source and scenario | Commit/tree, tool versions, fixture, seed, operations, results, artifact hashes and limits |
| R-11 | Asset authoring is reproducible | Blender recipe to validated mesh/rig/clip/material import with provenance and round trips |
| R-12 | Effects remain readable and comfortable | Original retro identity, shape plus color, clean comparisons and comfort options |
| R-13 | Animation and gameplay systems compose | Movement, combat, IK/layering, events, effects, sound, cameras and reset tested together |
| R-14 | Networking has explicit semantics | Authority, ordering, loss, reconnection, prediction/resync and incompatible-peer tests |
| R-15 | Durable state differs from replay and transport | Migration, atomic writes, namespaces, conflict/recovery and malformed-input handling |
| R-16 | Expensive work is budgeted and cancellable | Estimates, deadlines, checkpoints, cancellation and partial-output protection |
| R-17 | Platform and tool integrations are optional | Separately probed profiles cannot break default source/export |
| R-18 | Automation extends beyond playback | Live authoring, sweeps, build comparison, event clips and media/performance analysis |
| R-19 | Artifacts preserve meaningful structure | Versioned records, resources/manifests, unknown-version rejection and round trips |
| R-20 | Accessibility/input have explicit gates | Keyboard/focus/rebind, text scale, non-color cues, comfort and device evidence |
| R-21 | Packages are intentional | Export profiles, addon/tool separation, licenses, allowlists and metadata/secret checks |
| R-22 | Components work outside the museum | Minimal extraction scene and documented injected dependencies |
| R-23 | Breadth ships in coherent journeys | Cross-lab state/operation handoffs, not isolated badge accumulation |
| R-24 | No invented qualification | Logic, pixels, audio, provider, export, editor, native, transport, profiling and hardware differ |

## 4. Shared systems and module contract

The expanded host uses statically registered lab modules for new system/visual prototypes while preserving the original main.gd/world.gd routes. Implemented boundaries and actual source paths are in [implementation waves](docs/IMPLEMENTATION_WAVES.md). Modules expose metadata, readiness, setup/teardown, operations, bounded observations, fixture/reset, scenarios, and reusable extraction hosts. The host injects services; a module does not reach into arbitrary sibling scene paths. Full first-six extraction and remaining target systems remain open.

One implemented synchronous operation spine accepts validated requests and emits receipts/events. Actions carry a request ID, optional expected revision/epoch and typed bounded arguments. The inspector and optional HTTP/CLI/MCP client observe the same result. The names in expanded lab specs remain **target contracts**; callable descriptors come from the live registry and [runtime API](docs/RUNTIME_API.md). Wider session/queued-effect contracts remain specified in [DATA_CONTRACTS](docs/DATA_CONTRACTS.md) and [AUTOMATION_CONTRACTS](docs/AUTOMATION_CONTRACTS.md).

Shared systems include readiness/profiles, fixture registry, reset ownership, schema/migration, scenario/event records, clocks, live transport, CLI/MCP adapters, presentation tracks, Cappy orchestration, evidence manifests, cancelable jobs, asset provenance/import, analysis budgets, and source/export qualification. Their implementation and qualification tickets precede dependent lab tickets.

## 5. A lab is a complete interaction contract

Every entry specifies a player payoff; Godot mechanisms versus proposed lab types; at least three interaction steps; typed operations; a scenario and fixture; reset ownership; observable positive assertions; at least two meaningful failure cases; evidence channels; dependencies; an extractable component; and limits.

For implementation, add actual scene/source paths, installed API probes, profile readiness/fallback, precise argument/result schemas, scenario sequence and tolerances, fixture license/hashes, performance budgets, accessible input, and evidence locations. A qualification ticket follows implementation. Specs can evolve after a spike finds an API boundary; do not silently substitute a screenshot for a promised mechanism.

The first six retain bounded historical proof. Deepening includes richer movement/collision variation, simulation investigation, navigation behavior, rendering comparison, audio examination, and durable-state work. A previous seal does not qualify new depth. [ROADMAP](docs/ROADMAP.md) links all 192 lab implementation/qualification tasks, including those six deepening pairs.

## 6. Composed playable journeys

Eight public journeys are planned: Courier Circuit; Clockwork Duel; Weather Postcard; Story Caravan; Signal Orchestra; Two Worlds Together; Maker to Movie; and Device Expedition. [JOURNEYS](docs/JOURNEYS.md) defines cross-system acceptance and laboratory prerequisites. Each needs an enjoyable goal, useful feedback and clean recovery. The bootstrap currently offers a six-room tour.

Private composition builds twelve more opinionated experiences from qualified public components and original restricted fixtures. Private provenance and machine routes stay private. It pins an exact public revision and separately records the runtime revision actually verified. The public game must never require private composition or its research materials.

## 7. Delivery order

M0 is the tested bootstrap. M1 establishes module/operation/readiness/reset/evidence foundations and a broader playable core. M2 develops character, combat, animation, world, narrative, art and sound depth. M3 delivers live production automation, networking, asset/tool authoring and record workflows. M4 qualifies advanced rendering, performance, native/tool and interchange systems. M5 qualifies optional platform, mobile, web, multi-device and XR adapters where environments are available.

Milestones are waves, not permission to skip dependencies. The catalog DAG and shared-system gates determine execution order; [MILESTONES](docs/MILESTONES.md) defines exits. A late optional adapter cannot delay the default journey. A lower-cost fallback can ship with bounded proof while the advanced profile remains unverified.

## 8. Automated acceptance

Run actual operations against actual scenes and record semantic observations; setting expected final state is not acceptance. Use stable fixtures, ticks and ordering where possible. Physics, GPU pixels, audio encoders and timing require declared tolerances rather than universal bit-identical claims. Positive evidence must survive reset/re-entry and failure probes.

Headless behavior cannot establish visual quality. A nonblack frame cannot establish animation correctness. A receipt cannot establish capture. Provider success cannot establish encoded sound. A simulator cannot establish real controller, touch, XR or sensor comfort. Each lab declares required routes; [TEST_STRATEGY](docs/TEST_STRATEGY.md) defines gates.

The user is unavailable for physical-device testing. Complete feasible automated simulation, rendered desktop, media analysis, toolchain, network-process, export and simulator work; retain physical/human gates for later. Automatically recorded video is evidence of the executable, not a substitute deliverable.

## 9. Budgets, errors and boundaries

Default play is offline and inexpensive. Import/export destinations, recording, optional networking, external tools and costly work have explicit routes and ownership. Imports are staged before activation. Large fixtures, commands, event streams, shaders, native binaries and render jobs have size/time/resource limits. Failure returns a typed reason and leaves usable state; cancellation cannot replace a good artifact with partial output.

Networking defaults to explicit local sessions. Live automation binds loopback with scoped authentication for mutation. No arbitrary evaluation or shell command is exposed. Workers receive bounded recipes and source/asset manifests rather than hidden private paths. Distribution includes approved assets and licenses.

## 10. States and completion

Use specified, spiked, implemented, automated-verified, human-verified, release-ready or blocked. Track evidence per revision/adapter; a milestone or generated spec cannot promote runtime status. The first six catalog statuses describe existing bounded routes only.

Qualification requires ordinary play, operation equivalence, reset/lifecycle cleanup, hostile/failure cases, required rendered/audio/provider/editor/native/network evidence and extraction viability. A wave release adds its composed journey, independent source, exported artifact, budgets, license/privacy/content review and truthful pending physical gates. M0 alone cannot establish project-wide completion.

## 11. Scope boundaries

This is an original playable engine laboratory and reusable automation system. It is not an engine fork, copied game, compulsory cloud service, commercial backend, or promise of every API on every host. Native/web/mobile/XR examples qualify tested combinations. Retro style is preferred; modern rendering is used where it communicates a mechanism worth comparing.
