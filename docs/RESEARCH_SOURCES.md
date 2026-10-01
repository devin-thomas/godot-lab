# Research sources for the expanded lab

Reviewed 2026-10-01. These primary references support capability research and acceptance design. Documentation establishes API intent and constraints; it does not establish that Godot Lab implements a feature or that an actual host/provider/device passed. [BUILD_STATUS](BUILD_STATUS.md) owns that evidence, [SHOWCASE_CAPABILITY_COVERAGE](SHOWCASE_CAPABILITY_COVERAGE.md) maps proposed domains, and [SOURCE_INDEX](SOURCE_INDEX.md) records the existing project/art references.

Godot `stable` documentation can change. Pin the engine actually used for a spike and record the relevant API/version before implementation. Do not substitute `latest` documentation for a released-engine guarantee. A source-derived design, a tested engine outcome, and a physical-device outcome receive different labels.

## Godot runtime, authoring and rendering

| Primary source | What it informs | Qualification required here |
|---|---|---|
| [Command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) | Headless/editor/project argument boundaries and export automation | Real process exit/report; matching templates and executable launch |
| [Physics interpolation introduction](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html) | Independent simulation and rendering clocks | Qualified tick/output profiles; no inferred cross-host physics determinism |
| [Navigation documentation](https://docs.godotengine.org/en/stable/tutorials/navigation/index.html) | Maps, paths, agents and avoidance as separate mechanisms | Actual path/arrival, synchronized map and unreachable case |
| [Using AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) | Clip playback, blend spaces, layers and state transitions | Imported clips and real deformation/transition evidence |
| [SkeletonModifier3D](https://docs.godotengine.org/en/stable/classes/class_skeletonmodifier3d.html) | Custom post-animation skeletal modification and influence | Correct ordering, pose observations and modifier-disabled control |
| [Introduction to 3D](https://docs.godotengine.org/en/stable/tutorials/3d/introduction_to_3d.html) | Imported scenes and generated geometry mechanisms | Original assets, bounded generated geometry and import fidelity |
| [GLTFDocument](https://docs.godotengine.org/en/stable/classes/class_gltfdocument.html) | glTF scene/state import and export | Units, hierarchy, clips, UV/material/skin metadata and malformed content |
| [Runtime file loading and saving](https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html) | Runtime media/models versus imported bundled resources | Safe staging, size/path limits and standalone export behavior |
| [Optimization using MultiMeshes](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html) | Many instances with shared draw machinery | Bounded instance sweeps and measured profile; no blanket speedup claim |
| [CPU optimization](https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html) | Profiling and measurement before optimization | Warm workload, profiler overhead and actual bottleneck evidence |
| [Advanced post-processing](https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html) | Screen/depth effects and renderer-specific considerations | Actual backend, optional effects, viewport/overlay correctness |
| [Audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) | Signal routing, effects and bus control | Encoded output, headroom, mute behavior and original signal provenance |
| [Creating movies](https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html) | Engine offline movie output | Actual frame count/rate/audio plus explicit Movie Maker provider identity |
| [High-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) | Peer/authority/RPC mechanisms | Synthetic two-peer transport, duplicate/drop/reconnect and actual state reconciliation |
| [Setting up XR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html) | XR project/runtime setup | Synthetic action/pose and build lanes; physical headset lane stays pending |
| [Making editor plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html) | Optional reusable authoring tools | Tool lifecycle, scene changes, undo and export independence |

The reference set deliberately spans runtime mechanics, rendering, audio, authoring, performance, transport and export. An advanced API's presence is not a reason to change the foundation's Compatibility renderer. Renderer-specific stations should state availability and preserve usable fallback/explanation.

## Automation and media

| Primary source | Use in the plan | Evidence boundary |
|---|---|---|
| [Official scoped Cappy npm distribution](https://www.npmjs.com/package/@uppercut-labs/cappy) | Released CLI and the Godot adapter; this repository pins 0.1.0 | Installed package/lock integrity, exact vendored adapter bytes and real command/provider outcome |
| Released package's `configuration.md` | Scalar parameters, presets, time scale, cameras, event anchors, named builds, workspace and timeouts | A package capability still needs game-side implementation and a gate |
| Released package's `godot-adapter.md` | Prepare/ready/start lifecycle, replay payload ownership and semantic time | Real adapter handshake; ordinary exports remain independent of developer launch |
| Released package's `SKILL.md` | JSON envelope, exit statuses, capture/compare/timeline command semantics | `--no-capture` never establishes OBS recording; failed output remains failed |
| [OBS WebSocket protocol](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md) | Authenticated provider requests/events and recording lifecycle | Actual intended game source, real master and bounded owned-instance cleanup |
| [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html) | SSIM/PSNR, region/sample analysis and audio statistics | Decode the actual artifact with declared alignment/color/audio settings |
| [MCP specification, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25) | Thin typed tools, lifecycle and cancellation/progress transport | Proposed lab tools require real server/client sessions; MCP does not make gameplay deterministic |

The three package references live under `node_modules/@uppercut-labs/cappy/.agents/skills/cappy/references/` or its parent skill directory after `npm ci`. They are examined source material, not additional repository dependencies. The package's bundled adapter and license are intentionally preserved under `game/addons/cappy`; generated configuration, credentials and captures remain ignored.

Whole-frame SSIM/PSNR alone can miss a small broken interaction or wrong capture source. Compare aligned regions and event timing, retain discrepancy frames, and pair media scores with semantic observations. Audio analysis must inspect game-only encoded samples; player state or a dummy driver cannot prove pan, tone or attenuation. Transcription belongs to future original speech/caption fixtures, with tool version and known text recorded.

## Blender generation

[Blender's command-line arguments documentation](https://docs.blender.org/manual/en/4.0/advanced/command_line/arguments.html) establishes background script invocation and explicit Python error exit behavior. This retrieved page is a historical 4.0 reference, **not a selected Blender version for Godot Lab**. The current-version page was unavailable to the research fetch; use the actual qualified Blender executable's version/help and matching API reference before implementing generators.

The proposed pipeline records Blender version, input schema, seed, script/helper hashes, output hashes and provenance. Repeatability requires explicit defaults, ordering, units and scoped output locations. Binary equality of an export is a separate claim from equivalent topology/materials/animation after import. No private generator or externally authored game asset is required by the public plan.

## How to use a source in a lab specification

Record the official API or mechanism, the chosen engine/tool version, the bounded player interaction, and the gate that would fail if the mechanism were absent. For a renderer/device feature, add a capability probe and unavailable result. For media, identify the actual provider and artifact. For imported/generated content, connect source and import settings to tested behavior and licensing.

Keep research observations and recommendations distinct. A comparison project can motivate a richer operation system or evidence pipeline without becoming a runtime dependency. The public lab ships original/allowlisted fixtures and public mechanisms; private source paths, host mappings and production details remain outside these documents.
