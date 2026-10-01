# The 96-lab program

**96 substantive laboratory contracts across 16 wings.** Six bounded M0 interactions already exist; 90 future labs and deeper versions of the first six are specified. This is the complete program plan, not 96 shipped rooms or a plan to stop after the first six.

Each contract names a player payoff, real mechanism or explicit proposed contract, three or more interaction steps, typed operation signatures, original fixture, reset, observable assertions, failure cases, evidence channels, dependency IDs, reusable extraction, and limits. First-six expansion pages separate new ambitions from existing proof.

The source of truth is [planning/catalog.json](../planning/catalog.json). Read [SPEC](../SPEC.md), [milestones](../docs/MILESTONES.md), [dependency order](../docs/ROADMAP.md), and [BUILD_STATUS](../docs/BUILD_STATUS.md). APIs are primary-documentation leads until an installed-engine probe qualifies their signatures, renderer and target.

## Program shape

| Wave | Contracts | Meaning |
|---|---:|---|
| M0 | 6 | Delivered bounded baseline; first-six deepening remains specified. |
| M1 | 13 | Shared interaction/state spine and early player/authoring depth. |
| M2 | 34 | Core art, motion, physics, world, audio and UI comparisons. |
| M3 | 29 | Integrated streaming, jobs, captures, richer rendering and lifecycle systems. |
| M4 | 10 | Network resilience, compute/native boundaries and exported target qualification. |
| M5 | 4 | Browser-to-browser and physical mobile/XR gates. |

Wave counts describe the initial dependency-safe allocation. Implementation follows the full ticket DAG, not numerical IDs or a promise to finish all contracts in one build. An unavailable external/hardware path remains a gated specification.

## A coherent laboratory

Make capabilities discoverable, operations inspectable, fixtures trustworthy, and state/lifecycle boundaries reusable. These contracts connect the whole program rather than adding isolated API screens.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-006: Memory archive](LAB-006.md) | Write earned seals and comfort preferences then reload a real versioned file. | M0 / automated-verified |
| [LAB-037: Capability Compass](LAB-037.md) | Find a capability by payoff and see exactly why its live route is available or gated. | M1 / specified |
| [LAB-038: Operation Desk](LAB-038.md) | Invoke one typed operation from UI and automation and compare receipts and undo. | M1 / specified |
| [LAB-039: Fixture Pantry](LAB-039.md) | Choose safe original fixtures and preview their bounds before committing them to a lab. | M2 / specified |
| [LAB-040: Pause Vestibule](LAB-040.md) | Pause, resume and leave an active lab while inspecting cleanup and focus handoff. | M3 / specified |
| [LAB-041: Signal Switchboard](LAB-041.md) | Wire events between scene objects and inspect ordering, disconnection and duplicate subscription. | M1 / specified |

## Movement and embodied actions

Compare 2D/3D controllers, animation, targeting, contact transitions, cameras and navigation traffic. A repeatable route must still use real player/actor mechanics.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-001: Motion atelier](LAB-001.md) | Feel a real capsule move, jump and land against stairs and a solid block. | M0 / automated-verified |
| [LAB-008: Animation Loom](LAB-008.md) | Blend locomotion with a gesture and inspect transition timing rather than swapping clips blindly. | M1 / specified |
| [LAB-011: Camera Rig](LAB-011.md) | Try camera projection and occlusion behavior while moving through a readable course. | M1 / specified |
| [LAB-015: Skeleton Studio](LAB-015.md) | Place targets and inspect constrained skeletal motion and deformation. | M2 / specified |
| [LAB-042: 2D Movement](LAB-042.md) | Compare forgiving jump controls with exact collision in a compact2D platform course. | M1 / specified |
| [LAB-043: Combat Clock](LAB-043.md) | Land a readable attack and inspect hitboxes, invulnerability, hitstop and cancel timing. | M2 / specified |
| [LAB-044: Ledge Course](LAB-044.md) | Traverse slope, wall and ledge states while inspecting transition guards. | M2 / specified |
| [LAB-045: Platform Ferry](LAB-045.md) | Ride translating/rotating platforms and compare inherited velocity on departure. | M2 / specified |
| [LAB-046: Aim Range](LAB-046.md) | Compare ray, shape and projectile targeting with readable occlusion and collision masks. | M3 / specified |
| [LAB-047: Navigation Traffic](LAB-047.md) | Dispatch several agents through a bottleneck and inspect avoidance versus path planning. | M3 / specified |

## Physical and temporal systems

Explore rigid bodies, constraints, fields, hit timing, soft bodies and collision behavior with explicit tolerances. Reset and resource bounds are part of every mechanism.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-002: Gravity foundry](LAB-002.md) | Launch a weighted cube and inspect actual impulse, contacts and settling. | M0 / automated-verified |
| [LAB-021: Time Laboratory](LAB-021.md) | See pause, time scaling and interpolation affect simulation without freezing the inspector. | M2 / specified |
| [LAB-022: Destruction Cell](LAB-022.md) | Break an original assembly into bounded physical fragments and rebuild it. | M2 / specified |
| [LAB-048: Joint Arcade](LAB-048.md) | Connect2D bodies with pin/spring/groove joints and inspect limits and break policy. | M2 / specified |
| [LAB-049: Constraint Foundry](LAB-049.md) | Manipulate3D mechanical joints and inspect angular limits and solver stability. | M2 / specified |
| [LAB-050: Field Chamber](LAB-050.md) | Move bodies through gravity, damping and trigger zones and inspect overlap policy. | M2 / specified |
| [LAB-051: Cloth Sail](LAB-051.md) | Pin and release a small soft-body sail and inspect deformation and collision cost. | M3 / specified |
| [LAB-052: Collision Switchyard](LAB-052.md) | Toggle layers/masks and see which bodies, triggers and queries can interact. | M1 / specified |
| [LAB-053: Ballistics Tunnel](LAB-053.md) | Fire fast objects at thin obstacles and compare discrete/continuous collision behavior. | M3 / specified |
| [LAB-054: Ragdoll Recovery](LAB-054.md) | Switch an original rig between animation and physical bones and inspect recovery. | M3 / specified |

## World construction and traversal

Author tiles, terrain, navigation and seeded layouts, then load them as playable spaces. Inspect topology, chunk state and precision rather than merely generating a pretty scene.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-003: Pathfinder garden](LAB-003.md) | Dispatch a courier around a tower to a fixed destination. | M0 / automated-verified |
| [LAB-007: Tile Workshop](LAB-007.md) | Paint a playable2D room and see terrain seams and collision update together. | M1 / specified |
| [LAB-016: Terrain Foundry](LAB-016.md) | Sculpt or import terrain and compare visual form, collision and level-of-detail boundaries. | M2 / specified |
| [LAB-023: Procedural Garden](LAB-023.md) | Generate a seeded playable layout and inspect connectivity before entering it. | M2 / specified |
| [LAB-029: Streaming Depot](LAB-029.md) | Walk across scene boundaries while loading chunks and preserving local changes. | M3 / specified |
| [LAB-030: Large World](LAB-030.md) | Explore precision at large distances and compare an explicit origin strategy. | M4 / specified |
| [LAB-055: Grid Tactics](LAB-055.md) | Plan and execute a turn on a2D grid with cost, occupancy and undoable commands. | M2 / specified |
| [LAB-056: Voxel Quarry](LAB-056.md) | Edit a tiny voxel volume and inspect meshing, collision and chunk seams. | M3 / specified |
| [LAB-057: Navmesh Workshop](LAB-057.md) | Move an obstacle and inspect the difference between navigation rebake and runtime avoidance. | M3 / specified |
| [LAB-058: World Clock](LAB-058.md) | Advance a scoped day/weather clock and inspect gameplay triggers and visual change separately. | M2 / specified |

## Authored retro production

Build original texture-first surfaces, vertex shade, silhouettes, animation rhythms and gradient cards. Study authored choices with calibration views, attribute receipts and captures.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-004: Paint & light](LAB-004.md) | Separate painted shade, matte light and vertex shade on comparable geometry. | M0 / automated-verified |
| [LAB-060: Atlas Author](LAB-060.md) | Paint a tiny original motif atlas and inspect UV padding, sampling and repetition on modular geometry. | M2 / specified |
| [LAB-061: Vertex Shade](LAB-061.md) | Paint broad shade on geometry and inspect interpolation and triangulation before adding lights. | M2 / specified |
| [LAB-062: Silhouette Studio](LAB-062.md) | Compare original low-poly character shapes at gameplay and close-up distances. | M2 / specified |
| [LAB-063: Stepped Animation](LAB-063.md) | Compare stepped pose sampling with smooth simulation/camera response. | M2 / specified |
| [LAB-064: Shadow Cards](LAB-064.md) | Place authored contact gradients and shafts and inspect their camera-angle limits. | M2 / specified |

## Rendering and presentation

Compare shaders, particles, lights, fog, display pipelines and renderer profiles under real availability gates. Regional visual proof complements semantic state and measured costs.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-009: Particle Weather](LAB-009.md) | Tune a storm and compare CPU/GPU particle behavior under a bounded budget. | M2 / specified |
| [LAB-010: Light Archive](LAB-010.md) | Inspect how baked, authored and dynamic light change the same original room. | M2 / specified |
| [LAB-019: Shader Bench](LAB-019.md) | Adjust uniforms and see clean before/after output while inspecting shader diagnostics. | M2 / specified |
| [LAB-031: Renderer Gallery](LAB-031.md) | Compare the same fixture across Compatibility, Mobile and Forward+ with explicit support gates. | M2 / specified |
| [LAB-065: Fog Theater](LAB-065.md) | Compare depth haze and supported volumetric fog around readable silhouettes. | M3 / specified |
| [LAB-066: Viewport Mirrors](LAB-066.md) | Look through a live portal/monitor and inspect camera, texture and input forwarding boundaries. | M3 / specified |
| [LAB-067: Decal Printing](LAB-067.md) | Place original projected marks and compare them with mesh-backed marks under supported renderers. | M3 / specified |
| [LAB-068: Display Laboratory](LAB-068.md) | Compare clean, pixel-scaled, palette and optional CRT output without weakening controls. | M2 / specified |
| [LAB-069: Compute Garden](LAB-069.md) | Run a small compute fixture and compare output against a CPU reference with honest availability. | M4 / specified |
| [LAB-070: Tone Observatory](LAB-070.md) | Compare exposure, tone mapping and color grading while preserving meaningful luminance roles. | M3 / specified |

## Sound as interaction

Explore spatial sources, buses, mixing, synchronized music and reviewed voice/captions. Actual encoded audio establishes a different claim from source playback flags.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-005: Signal chamber](LAB-005.md) | Hear distance and stereo change around a visible original tone emitter. | M0 / automated-verified |
| [LAB-020: Acoustic Rooms](LAB-020.md) | Compare bus effects, reverb and filters while walking between simple acoustic spaces. | M2 / specified |
| [LAB-071: Mixer Desk](LAB-071.md) | Route original stems into lab-owned buses and inspect gain, solo and clipping safely. | M2 / specified |
| [LAB-072: Music Conductor](LAB-072.md) | Change intensity on a beat boundary and inspect synchronized stems rather than abrupt restarts. | M3 / specified |
| [LAB-073: Voice & Captions](LAB-073.md) | Play original speech with timed captions and compare transcript, timing and audible evidence. | M3 / specified |

## Game state with meaning

Use branching dialogue, guarded statecharts, objectives, transactional inventory and cancellable sequences. Operations preserve stable identity, undo/recovery rules and original fixtures.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-014: Dialogue Machine](LAB-014.md) | Choose branches in original dialogue and undo a choice without corrupting story state. | M1 / specified |
| [LAB-074: Statechart Playhouse](LAB-074.md) | Manipulate a small character state machine and inspect guards, entry/exit and interrupted actions. | M2 / specified |
| [LAB-075: Quest Weave](LAB-075.md) | Complete original objectives in different orders and inspect dependency and undo semantics. | M2 / specified |
| [LAB-076: Cinematic Rails](LAB-076.md) | Compose an interactive camera/animation sequence with skip, resume and bounded cancellation. | M3 / specified |
| [LAB-077: Inventory Alchemy](LAB-077.md) | Combine original items and inspect transactional recipes, limits and undo. | M2 / specified |

## Readable and adaptable control

Treat focus, rebinding, text, comfort and typed drag/drop as maintained systems. Alternate paths use shared operations while accessibility/hardware evidence remains explicit.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-012: Input Atelier](LAB-012.md) | Rebind actions and see prompts follow actual input events without losing essential controls. | M1 / specified |
| [LAB-013: UI Workshop](LAB-013.md) | Operate a responsive control panel by keyboard and pointer with one predictable focus path. | M1 / specified |
| [LAB-078: Locale Pavilion](LAB-078.md) | Switch original translations and inspect text direction, plural rules and saved language choice. | M3 / specified |
| [LAB-079: Focus Labyrinth](LAB-079.md) | Navigate menus, dialogs and a3D panel with keyboard focus and inspect accessibility probes. | M3 / specified |
| [LAB-080: Comfort Controls](LAB-080.md) | Tune motion, flash, text and input assists with immediate preview and scoped persistence. | M2 / specified |
| [LAB-081: Drag & Inspect](LAB-081.md) | Drag typed resources between panels and inspect validation, preview and undo. | M2 / specified |

## Authority and continuity

Qualify actual paired-process sessions, prediction, reconnect, fault injection and bounded RPC. Transport, identity, convergence and browser availability receive separate tests.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-024: Network Commons](LAB-024.md) | Join two local processes and inspect server authority and replicated player state. | M3 / specified |
| [LAB-082: Prediction Track](LAB-082.md) | Compare authoritative motion with client prediction and reconciliation under controlled delay. | M4 / specified |
| [LAB-083: Reconnect Harbor](LAB-083.md) | Drop and rejoin a local session without duplicating owned entities or losing committed state. | M4 / specified |
| [LAB-084: Network Chaos](LAB-084.md) | Inject loss, jitter, duplication and reordering and inspect recovery instead of hiding transport failures. | M4 / specified |
| [LAB-085: RPC Gatehouse](LAB-085.md) | Send allowed and invalid RPC requests and inspect authority, payload limits and version checks. | M4 / specified |
| [LAB-086: WebRTC Bridge](LAB-086.md) | Connect two browser-capable peers through an explicit local signaling adapter and inspect failure modes. | M5 / specified |

## Reusable scenes and trustworthy takes

Make replay, live control, source-bound captures, parameter sweeps, camera takes and evidence comparison part of the program. The official Cappy integration drives the real systems and cannot replace live play.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-025: Replay Observatory](LAB-025.md) | Record meaningful operations and replay a versioned semantic timeline. | M1 / specified |
| [LAB-087: Live Control](LAB-087.md) | Drive a running lab through a narrow typed command channel and inspect cancellation and receipts. | M3 / specified |
| [LAB-088: Source-bound Capture](LAB-088.md) | Capture only the declared game window/process and verify the source identity before accepting media. | M3 / specified |
| [LAB-089: Parameter Sweeps](LAB-089.md) | Schedule bounded scenario variations and compare their actual outcomes with resumable jobs. | M3 / specified |
| [LAB-090: Camera Takes](LAB-090.md) | Author reusable camera routes and record them without disabling ordinary playable scenes. | M3 / specified |
| [LAB-091: Golden Assertions](LAB-091.md) | Compare declared image/audio/state regions and inspect why a regression passes or fails. | M4 / specified |

## The engine as an authoring platform

Expose editor undo, native-extension boundaries, custom imports and export qualification. Editor/native/platform adapters are optional gates with reusable narrow contracts.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-026: Editor Toolroom](LAB-026.md) | Build a small editor panel that changes scene data with working undo/redo. | M3 / specified |
| [LAB-027: Native Bridge](LAB-027.md) | Compare a narrow GDExtension calculation with a typed GDScript reference. | M4 / specified |
| [LAB-093: Import Plugin](LAB-093.md) | Import an original custom data format through editor tooling with reimport and diagnostics. | M3 / specified |
| [LAB-094: Export Profiles](LAB-094.md) | Build explicit native/web profiles and inspect included assets, runtime route and unsupported gates. | M4 / specified |

## Measured cost and ownership

Compare crowd layouts, jobs, LOD and lifecycle memory using controlled fixtures and recorded sampling windows. Counters can be unavailable; no universal speedup or hardware budget is invented.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-017: Crowd Balcony](LAB-017.md) | Compare individual meshes and instancing under the same crowd layout and camera. | M2 / specified |
| [LAB-028: Thread Mill](LAB-028.md) | Run a bounded cancellable data job without mutating the scene from worker threads. | M3 / specified |
| [LAB-036: Profiling Booth](LAB-036.md) | Measure a controlled expensive scene before and after one explained optimization. | M2 / specified |
| [LAB-059: LOD Walk](LAB-059.md) | Walk an identical camera route and inspect mesh detail transitions, culling and visual discontinuity. | M3 / specified |
| [LAB-092: Memory Observatory](LAB-092.md) | Repeat entry/reset/exit and inspect resource growth, leaks and bounded caches. | M3 / specified |

## Durable and portable assets

Inspect custom resources, scene import and Blender round trips with identities and provenance. Unknown fields, lost attributes and external dependencies require explicit policy.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-018: Resource Cabinet](LAB-018.md) | Save and reload a custom Resource while inspecting dependencies and stable identities. | M1 / specified |
| [LAB-035: Import Studio](LAB-035.md) | Inspect imported meshes, materials and animation against original source fixtures. | M2 / specified |
| [LAB-095: Blender Round Trip](LAB-095.md) | Carry an original rigged, vertex-painted modular asset from source to Godot and back through a bounded interchange path. | M3 / specified |

## Real exported environments

Run browser and mobile interaction paths through explicit export/storage/input adapters. Automated browser/sensor fixtures never claim physical mobile qualification.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-032: Web Portal](LAB-032.md) | Export a small route and try browser-specific input, storage and restart behavior. | M4 / specified |
| [LAB-033: Mobile Field Kit](LAB-033.md) | Try touch controls and sensor adapters with visible simulated/real distinction. | M5 / specified |

## Spatial input with honest gates

Separate actual runtime/tracking support from labeled pose replay. Controller and hand experiments preserve a meaningful desktop fixture path and safe tracking-loss behavior.

| Lab | Player payoff | Wave / state |
|---|---|---|
| [LAB-034: XR Room](LAB-034.md) | Interact through tracked input while inspecting real versus fixture poses. | M5 / specified |
| [LAB-096: XR Hands](LAB-096.md) | Inspect tracked or recorded hands, pinch grabs and loss-of-tracking behavior on original objects. | M5 / specified |

## Deepen the delivered baseline

The existing motion, rigid-body, fixed-target navigation, three-sample material, single spatial tone and seal checkpoint rooms prove a narrow foundation. Their expansion contracts add reusable boundaries, harder failure/lifecycle cases, more meaningful interactions and broader evidence:

- [LAB-001: Motion atelier deepening](LAB-001-EXPANSION.md): Separate reusable player/controller modules from host assembly. Add input buffering, coyote time and analog profiles with boundary assertions.
- [LAB-002: Gravity foundry deepening](LAB-002-EXPANSION.md): Add mass/friction/restitution sweeps with recorded tolerances. Compare jointed mechanisms and high-speed collision.
- [LAB-003: Pathfinder garden deepening](LAB-003-EXPANSION.md): Add selectable destinations and explicitly unreachable targets. Compare authored, runtime-rebuilt and avoidance routes.
- [LAB-004: Paint & light deepening](LAB-004-EXPANSION.md): Develop original atlas/UV and vertex-color round-trip examples. Add identical-fixture renderer and shader-profile comparisons.
- [LAB-005: Signal chamber deepening](LAB-005-EXPANSION.md): Add buses, effects, synchronized music and reviewed speech/captions. Exercise muted/missing-device/unsupported-output paths.
- [LAB-006: Memory archive deepening](LAB-006-EXPANSION.md): Add explicit schema migration and unknown-field preservation policy. Demonstrate durable idempotent transactions, recovery and undo.

## Add or qualify a lab

Use [TEMPLATE](TEMPLATE.md) and [EXTENSION_CONTRACT](../docs/EXTENSION_CONTRACT.md). A catalog row is not a passing API badge. Implementation and qualification tickets must establish the named interaction, negative cases, reset/exit behavior, reusable component and appropriate logic/render/audio/provider/transport/editor/export/profile evidence. Human and physical gates stay separate.
