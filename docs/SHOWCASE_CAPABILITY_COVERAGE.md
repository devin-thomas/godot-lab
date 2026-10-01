# Showcase capability coverage

Planning snapshot: 2026-10-01. The six-room build establishes a foundation, not the intended breadth of Godot Lab. This matrix translates mechanisms studied in an automated showcase into reusable **playable** stations. It describes mechanisms and acceptance design without depending on that showcase's source, assets, infrastructure or private production plan.

Current proof belongs to [BUILD_STATUS](BUILD_STATUS.md). `Implemented foundation` means a bounded existing station and scenario, not full coverage of that row's expansion. `Proposed` means no corresponding runtime integration is claimed. This matrix is a coverage lens; the lab catalog owns stable lab IDs and detailed station specifications. New interactions use the proposed shared contracts in [AUTOMATION_CONTRACTS](AUTOMATION_CONTRACTS.md).

| Mechanism/domain | Playable lab payoff | Automated proof required | State here |
|---|---|---|---|
| Character motion and collision | Jump, land, climb or compare grounded movement profiles | Real obstacle rejection, floor contact and equivalent input dispatch | Implemented foundation; advanced profiles proposed |
| Rigid-body impulse and settling | Launch, stack and tune mass/impulse/contact behavior | Displacement/contact/settling within named tolerances; disabled collision fails | Implemented foundation; sweeps proposed |
| Navigation and avoidance | Set targets, add obstacles and compare routes | Reachable/non-straight path, unreachable result, map readiness and timeout | Implemented foundation; crowds/dynamic obstacles proposed |
| Texture/material comparison | Compare nearest textures and material modes with fixed references | Sample-specific changes, reference invariance and actual pixels | Implemented foundation; richer import/material lanes proposed |
| Spatial audio | Move a listener and hear pan/attenuation | Encoded original tone, RMS distance response, stereo reversal and source identity | Implemented foundation; buses/cues/speech proposed |
| Checkpoints and restart | Earn/reset seals and inspect local storage semantics | Actual file, invalid-input preservation and fresh-process recovery | Implemented foundation; slots/migrations/import proposed |
| Typed operations and experiments | Inspect parameters, change a station and see an operation receipt | One domain implementation across UI/scenario/CLI/MCP; invalid types fail | Proposed |
| Fixed clocks and interpolation | Compare simulation tick rate, output frame rate and presentation speed | Tick/event invariance at qualified profiles; unsupported scale rejected | Proposed |
| Seeded fixtures and variants | Rebuild an authored scene from a seed and compare one named factor | Repeatable resolved inputs; separate RNG streams; changed seed/variant detectable | Proposed |
| Local live CLI/MCP control | Drive the running station while inspecting state/events/screenshots | Fresh-agent adaptive session, bounded calls, auth/reconnect/backpressure and replay | Proposed |
| Live control during Cappy freeform capture | Perform operations while the same visible world is recorded | Same run/epoch in live receipts, Cappy payload and replay; no second simulation | Proposed |
| Named cameras and clean presentation | Switch wide/close/follow views and toggle explanatory overlays | Framing changes while gameplay state/events remain equivalent | Proposed |
| Event timelines and anchored derivatives | Select an event and inspect a clip/still tied to its actual moment | Timeline-to-master alignment; required unresolved anchors fail | Proposed |
| Cross-build visual comparison | Compare one deliberate rendering/material change | Source/profile match, SSIM/PSNR plus region checks and planted regression | Proposed |
| Offline Movie Maker output | Export a scene at a chosen frame rate independently of OBS | Actual frames/audio, constant rate, duration/count/color and provider label | Proposed |
| Scripted Blender geometry | Generate a prop from bounded parameters and seed | Generator/helper versions, topology/units/hashes and Godot import checks | Proposed |
| Atlas painting, UV tiling and vertex colors | Paint original texture blocks and compare imported shading | UV/color/texture source correspondence; changed import setting detected | Proposed |
| Procedural rigid assemblies | Reconfigure an original articulated machine and trigger motion | Joint hierarchy, transforms, bounds and operation-driven pose changes | Proposed |
| Skinned animation and blending | Blend authored clips, layer a gesture and inspect bone/skin response | Imported clips, blend transitions, bone transforms and actual deformation | Proposed |
| Procedural skeletal modification | Aim or place feet on uneven geometry | Modifier ordering, ray contacts and pose changes; missing modifier fails | Proposed |
| Destruction and chain reactions | Break original pre-fractured pieces and trigger a controlled cascade | Contact thresholds, piece count/mass, event ordering and bounded physics | Proposed |
| Effects and hitstop | Trigger original impacts/trails/shockwaves and tune lifetime | Tick-based age, visible growth/fade, hold/merge semantics and lifetime cleanup | Proposed |
| Event-driven original audio | Trigger a cue from impact and compare pitch/voice limits | Encoded onset alignment, spectrum, overlap/voice cap and clipping checks | Proposed |
| Retro internal viewport and post-processing | Compare pixel scales, optional filters and native-readable HUD | Internal/output resolution, nearest sampling, readable overlays and clean plate | Proposed |
| Lights, shadows and renderer-specific effects | Compare explicitly gated rendering features | Actual backend, visible feature and graceful unavailable result | Proposed |
| Performance and instance scale | Increase a bounded instance count and inspect the cost | Warm timing/resource trend, caps and a planted overload/leak control | Proposed |
| Imported resources and safe runtime content | Preview original assets, reject invalid content and retain metadata | Staging/size/path/schema checks; import cancellation leaves no half-adopted state | Proposed |
| Local multiplayer authority/reconnect | Run a synthetic second peer and compare authoritative state | Duplicate message, conflict, drop/rejoin snapshot and bounded transport | Proposed |
| Export/toolchain capability | Build a platform package and inspect how it differs from source play | Exact templates/entrypoint/renderer/manifest and launched executable where possible | Windows foundation implemented; other lanes proposed |
| XR action, pose and viewer replay | Use synthetic action/pose fixtures before later headset interaction | Action mapping, pose schema, desktop replay and presentation/state separation | Proposed; physical headset acceptance deferred |
| Automated scene authoring and self-review | Create a new bounded station experiment, then inspect its evidence | Fresh agent authored source, passed gates, inspected actual media and reported limits | Proposed |

## Depth expected from each domain

Every proposed domain needs more than a screenshot or a toggle. Its station should expose an interesting action, a legible cause/effect comparison, bounded typed controls and a recovery path. Its documentation should explain what the engine is doing, where its limits are, how to reuse it, and what the evidence establishes. Its scenario should have a positive case, a meaningful negative control and a reusable evidence recipe.

For example, the destruction domain should let a player change a bounded contact threshold, strike a structure, observe the difference between an intact rigid body and original pre-fractured pieces, reset, and inspect fragment/event counts. Automation should use the same strike operation, verify real contacts and piece lifetimes, capture visible breakage, and fail when the impact or fracture path is disabled. A final-state counter alone is inadequate.

The authoring domain should connect original source generation to playable imported behavior. A generated GLB with the correct hash still needs scale, material, skin, animation and collision checks appropriate to its claim. An attractive static render cannot substitute for those import checks.

## Coverage and acceptance are separate

An automated cinematic workflow can have richer commands, assets and rendering than a small playable foundation. Conversely, a well-recorded set piece does not prove station discovery, focus navigation, reset/exit, ordinary controls, persistence isolation or repeated play. Godot Lab must preserve the former breadth while adding the latter product requirements.

Do not infer renderer portability, mobile performance or headset comfort from desktop footage. Same-host state equality, frame equality, semantic outcome and human experience are different evidence lanes. Rendering noise needs a recorded tolerance or retained discrepancy, not an undocumented rerun until green.

The expansion is complete only when catalog status, runtime discovery, operation schemas and evidence agree. Proposed stations stay labeled proposed; missing providers remain unavailable; physical gates remain pending. Implemented stations remain usable without developer capture tools.

## Sequencing

Build the common operation/run/evidence layer first so new domains share mechanics rather than accumulating special-purpose scripts. Then add original authoring, animation, effects and presentation as complete vertical stations. Follow with comparisons/matrices/performance and transport/export/XR lanes. Capture representative cases after semantic qualification, and allocate expensive rendering to qualified worker volumes. This order expands both artistic range and automation depth without turning the museum into a collection of disconnected demos.
