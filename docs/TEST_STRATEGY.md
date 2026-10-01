# Automated testing and evidence

The user is unavailable for physical or human testing during this delivery. Automated verification is therefore a release-work requirement, while human/device gates remain explicitly deferred.

## Evidence ladder

| Evidence | What it can establish | What it cannot establish |
|---|---|---|
| Parse/import | Scripts/resources load under named engine | Playability or correct outcomes |
| Headless simulation | Real node/state outcomes, reset, bounded scenarios | Shader appearance or audible sound |
| Windowed replay | Rendered route boots and visible actions occur | Human comfort or physical controller behavior |
| Encoded movie/audio | Frames, temporal progression, audio channel energy/timing | Real display/speaker output |
| Cappy/OBS capture | Named provider connected and produced inspected recording | Behavior on another user's setup |
| Export smoke | Actual exported executable launches and runs scenario | Signed distribution or untested platforms |
| Human/device session | Named person/device/input experience | Automatic universal support |

Every report identifies commit/build, engine version, OS/renderer, command, scenario ID/version, fixture/seed, assertions, artifact paths, outcome, and limits. Raw artifacts remain local and ignored. Curated public summaries remove absolute machine paths, usernames, credentials, unrelated windows, and recording metadata.

## First-release checks

These are M0 bootstrap checks; they do not qualify the 96-lab expanded program.

Collision checks should detect floor contact, wall blocking, jump movement, and reset. Physics checks should detect an impulse's meaningful displacement and settling/contact behavior. Navigation checks should verify arrival through the allowed region around an obstacle. Materials need rendered comparison, not only a parameter assertion. Audio needs encoded non-silent output and channel/position analysis where panning is claimed. Persistence needs save/load, process restart, invalid/truncated data, and scoped reset checks.

Run the integrated route through entry, action, reset, exit, and re-entry for every lab. Check that instructions and visible metrics match the actual result. Bound every scenario by time/frames so a broken target cannot hang the suite. Simulations use appropriate tolerances rather than claims of portable bit-identical physics.

## Analysis tools

Use FFmpeg/ffprobe for dimensions, duration, frame extraction, black-frame detection, freezes, and audio channels/energy. Listen or inspect spectrograms where channel statistics leave ambiguity. Transcription is useful only for spoken material; the baseline synthetic lab tones do not need transcription. State reports remain the primary truth for semantic outcomes, and screenshots/captures support visual assertions.

## Deferred gates

Human comfort, full controller hardware behavior, platform-specific input glyphs, speakers/headphones, mobile/XR hardware, physical-device performance, and unsupported export platforms remain deferred until they have evidence. An automated pass must name exactly the host and route it tested.

## Expanded gates

| Gate | Real observation | Deliberate negative control |
|---|---|---|
| Operation parity | UI/scenario/CLI/live/MCP produce equivalent semantic receipts | Invalid args, stale revisions, conflicting duplicate IDs |
| Lifecycle/isolation | Repeated entry/reset/exit releases resources and preserves unrelated state | Exit during job/peer/audio activity |
| Animation/combat | Pose/event/root motion, hit windows, effect/audio timing | Missing clips, invalid transitions, contact outside window |
| Rendering/display | Actual temporal frame/region changes at named profile | Unsupported renderer, frozen/black frames, mismatched look |
| Audio | Decoded tone/bus/position/cue and authored speech timing | Silence, clipping, channel swaps and missing cue |
| Network | Separate real peers, authority and convergence | Delay/loss/duplicate/disconnect/incompatible/unpaired peer |
| Authoring/interchange | Actual editor/tool execution and imported attribute round trip | Broken rig, UV/color loss, missing attachment/license |
| Jobs/performance | Admission, timing/memory, checkpoints, bounded progress | Cancel, capacity shortage, stale recipe and interrupted owner |
| Production | Same-session live control + Cappy, event/movie alignment | Provider loss, wrong window, stale source and partial output |
| Extraction/export | Minimal independent component scene and actual artifact launch | Missing optional plugin/native ABI/SDK and sibling dependency |

Golden media comparisons align source/fixtures/camera/look/renderer, then use declared metrics and tolerances. SSIM/PSNR alone cannot judge aesthetic intent; nonblack alone cannot prove a mechanism. Speech transcription applies only to actual original voice fixtures. Parameter sweeps have bounded valid ranges and retain failed samples.

## Planning-source qualification

`python scripts/plan.py --check --self-test` validates 96 contracts, all 16 wings, preserved lab identities, wave/dependency graphs, eight public journey prerequisites, generated specs/tickets/matrix/order and local links. It deliberately rejects duplicate IDs, unknown/cyclic dependencies, invented runtime promotion, baseline drift, missing failures, invalid operations, lost legacy identities, unknown journey prerequisites, omitted first-six depth qualification, generated drift and dangling links. These checks qualify planning consistency, never the future game's behavior.
