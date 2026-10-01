# Automation as part of the playable lab

The product is a playable executable. Automation operates its real mechanisms, records what happened, and makes the results inspectable. A developer can learn a capability by playing a station, reading its explanation, driving the same operation, and examining evidence. Recording software remains optional for ordinary play.

**The runtime commands, six scenarios and bounded capture workflow below are implemented. Everything under Expansion design is proposed.** The typed registry, general CLI/MCP adapters, live API, parameter matrices, named cameras, time-scale support and broader evidence bundles need their own implementation and acceptance gates. [BUILD_STATUS](BUILD_STATUS.md) owns observed results; [AUTOMATION_CONTRACTS](AUTOMATION_CONTRACTS.md) owns the proposed contracts.

## Runtime commands

Run from the repository root with the installed Godot binary available as `godot`:

```sh
godot --path game
godot --headless --path game -- --verify --report=/absolute/path/report.json
godot --path game -- --tour
python scripts/check.py
```

Use a real absolute report path for the target OS. Check BUILD_STATUS for the engine path and supported script options. Godot consumes arguments before `--`; the project reads its own scenario flags after it. See the [official command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html). `--headless` uses a dummy audio driver, so it cannot establish audible output.

## Scenario contract

A scenario has a stable ID/version, fixture baseline, bounded action sequence, expected semantic outcomes, simulation tolerance, and camera route when it is recordable. Reset before replay. Preserve the actual operation path. Prefer semantic observations such as arrival/contact/save validation over brittle exact frame pixels.

`--verify` is an assertion route. `--tour` is a presentation route. A tour recording supports appearance and timing; it does not by itself prove every assertion or ordinary input binding. Exported executables receive their own smoke route.

## Cappy integration

The official npm package is `@uppercut-labs/cappy`, pinned to `0.1.0` in optional developer tooling with Node 24 or later. The released Godot addon is preserved with its provenance and license in `game/addons/cappy`. Its package identity and adapter behavior must remain tied to that released distribution. Record the tested package version and provider result in BUILD_STATUS.

```sh
npm ci
npm run cappy:setup
npm run cappy -- scenarios --json
npm run cappy -- doctor --json
npm run test:cappy
```

Setup writes ignored local `cappy.config.json`. The replay check launches the game's `--automation` route, discovers six scenarios (`motion`, `physics`, `navigation`, `materials`, `audio`, `persistence`), records a bounded operation timeline, and compares semantic replay. It does not itself record video or claim bit-identical physics.

For a real local Windows OBS recording, `npm run capture:setup -- <existing-portable-OBS-root>` creates an isolated ignored `.local/obs` profile on WebSocket port 4467. `npm run capture -- motion` captures the named game scenario; use another listed scenario ID for a different lab. The default is a master-only recording to keep local resource use bounded. FFmpeg uses two threads to inspect small sampled frames, rejects black/flat output, and extracts an actual master frame beside the capture report. Optional derivative presets are separate. See BUILD_STATUS for actual provider results; successful setup is not recording proof.

For the signal experiment, run `npm run capture -- audio`, then `npm run test:audio`. The gate analyzes actual OBS game-process-only audio for non-silence, near/far attenuation, swapped stereo dominance, and the expected synthetic tone. Phase windows come from recorded AUDIO_PHASE events. A playing flag or dummy driver is not audio proof. Finish with `npm run capture:stop`; it checks the isolated instance identity and refuses to stop an active recording.

Cappy/provider recording is distinct from Godot's own `--write-movie` output. A local movie can prove encoded frames/audio while the OBS provider is unavailable. Report that boundary honestly. OBS WebSocket credentials stay in local environment/managed configuration; never pass them through public URLs, reports, screenshots, or commits.

## Capture lifecycle

The released Godot adapter's actual API is the boundary for new hooks:

| Released API | Game responsibility |
|---|---|
| `register_scenario(id, display_name, parameters, prepare, start, options)` | Register before the first-frame handshake; `options.validate` returns an empty string or a rejection reason |
| `set_replay_provider(record_start, record_stop, replay_prepare, replay_start, deterministic)` | Capture/validate the game's own versioned payload; current foundation passes false for deterministic |
| `declare_capabilities(names)` | Advertise only features the game applies and has qualified |
| `op.mark_ready()` | Hold a stable scene until the controller starts it |
| `op.event(name, t_msec, payload, duration_msec)` | Supply operation-relative simulation milliseconds and small stable payloads |
| `op.complete(result, payload_bytes, format)` / `op.fail(code, message)` | Supply one terminal outcome; freeform stop hands off exact replay bytes |
| `op.cancelled` / `op.stop_requested` | Tear down cancellation or end a running scenario/replay early through its real lifecycle |

The addon is inert without Cappy's launch environment and accepts only loopback endpoints. Release exports ignore it unless a capture-only local override enables `cappy/allow_release_builds`; never enable that setting in the shipped project or distribute the override. The game/addon does not call OBS or FFmpeg. Restore time scale/camera on terminal outcome or cancellation after those proposed capabilities are added.

1. Probe the named provider and package version; record unavailable status explicitly.
2. Reset the lab; establish its source, camera, resolution, and bounded route.
3. Start recording, run the real scenario, and stop recording even on failure.
4. Inspect output existence, duration, resolution, frame progression, visible mechanism, and encoded audio where required.
5. Attach the state report and capture result to the same scenario/build identity.

Developer capture is an explicit local action, not automatic recording of a player's session. The game remains playable without Cappy, Node, FFmpeg, OBS, or network access.

## Expansion design

The following is a specification, not a list of working integrations. Its scope extends the foundation into a reusable playable automation workshop. Each station still needs discoverable controls, readable feedback, reset, exit, documentation and evidence under the [extension contract](EXTENSION_CONTRACT.md).

### One operation path and one running world

The player sees purposeful buttons and feedback. Automation sees the same operation's typed arguments, defaults, bounds and result codes. Thin entry adapters enter one dispatcher and one authoritative running world.

| Surface | Proposed responsibility | Acceptance proof |
|---|---|---|
| Player UI, keyboard and controller | Translate input into domain operations; show result and recovery | Equivalent inputs produce the same applied operation and semantic outcome |
| Scenario runner | Compose bounded operations and observations against an isolated baseline | Replacing the real mechanism with a constant final state fails a gate |
| Local developer CLI | Discover operations, apply them, query state, run/replay/export records | Invalid input fails before mutation; actual receipt and exit code returned |
| MCP adapter | Narrow discovery, operation, query and evidence tools through the shared client | A fresh agent changes course from observed state and produces a replayable log within its budget |
| Loopback live API | Authenticate bounded clients, queue valid operations and serve read-only queries | Wrong token, malformed frame, conflict, reconnect and saturation leave play usable |
| Official Cappy adapter | Prepare scenarios, provide freeform replay payloads and emit timed events | Real package commands operate the same world and produce provider artifacts |

Live driving and Cappy freeform recording must coexist. Cappy may own launch and recording, but it must not suppress the live server or create a second simulation. Receipts, queries and the Cappy payload must identify the same run ID, epoch and source fingerprint. Prove it by applying a client operation during actual freeform recording, querying its result, then replaying that operation from the captured session. A socket connection or recording of an idle world is insufficient.

Developer live control is disabled by default and needs an explicit launch option. Ordinary exports must not start a listener or require Node. Remote orchestration runs local clients on a qualified worker host; public developer control remains loopback.

### Simulation, seed and presentation

Keep simulation ticks separate from render frames and wall time. Apply gameplay operations at defined tick boundaries and advance authored effects/scenario deadlines from simulation time. Monotonic wall time controls launch/provider watchdogs and emergency cancellation. Record applied operations, not merely accepted requests. Queries and camera sampling cannot change the gameplay digest.

The proposed clock profile names simulation rate, output rate and time scale. Begin with 60 Hz simulation and a small qualified set of output rates. To preserve a fixed simulation delta with `Engine.time_scale = s`, evaluate a physics tick frequency of `simulationRate * s`; reject non-integer or out-of-budget combinations. This is a design to qualify, not current lab support. Interpolation supplies presentation between ticks. [Godot's interpolation guide](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html) describes the clocks without promising portable rigid-body determinism.

Use named RNG streams for gameplay, geometry, materials, effects and audio so cosmetic draws cannot shift gameplay. Record resolved parameters and seed derivation. A build variant changes one documented factor; arbitrary host differences are not controlled variants.

Report three distinct proof levels: semantic replay within tolerances; per-tick state equality on one pinned host/build; and frame/audio equality for one qualified rendering setup. Prove each independently. Current foundation replay establishes the first, and does not advertise deterministic physics.

### Scenario and freeform lifecycle

A scenario names its stable ID/version, fixture, operations, observations, reset behavior, duration and resource ceiling. Preparation reconstructs the lab and waits for import/navigation readiness. Mark Cappy ready only once the baseline is stable and hold it until the start callback after OBS recording starts. Complete after assertions and bounded cleanup; fail with a concrete code on assertion or timeout.

Freeform recording logs applied player/live operations and resolved context in an isolated namespace. Stop produces a versioned payload. Replay validates the complete payload before preparing a fresh baseline. The working four-second fixture proves a limited automatic input route; arbitrary registered operations, ordinary UI driving, reconnect and cancellation need later gates. In released Cappy, only sessions created by `record` are replayable.

Room reset preserves earned player progress. Exit cancels jobs/subscriptions, releases per-room resources and restores hub controls. Repeated entry/reset/exit must plateau in resource usage. Replay may not adopt arbitrary paths, executable code or tokens from its payload.

### Official Cappy capability expansion

Cappy 0.1.0 supports the following tool features. Package availability is distinct from this game's support. Check the installed package's help and references on upgrades.

| Released package feature | Lab work required | Gate before claiming support |
|---|---|---|
| Typed scalar parameters | String/number/integer/boolean schemas with ranges/enums/defaults, resolved through domain validation | Invalid and unknown parameters fail before reset or recording |
| Freeform record/replay | Complete applied-operation payload, run context and expected result | Replay matches; edited operation or state expectation fails |
| `timeScale`, package range 0.1-4 | Advertise `time_scale` after clock profiles pass | Half speed preserves semantic ticks and changes presented duration; unsupported rate refused |
| Named camera presentation | Advertise `alternate_cameras` with stable IDs | Framing changes while gameplay records remain equal; unknown camera refused |
| Named builds and `compare-builds` | Complete launch fields, exact source and deliberate variant | Same source/profile identified; planted visual regression detected |
| Event-anchored derivatives | Stable event types/payloads and simulation times | Anchor selects visible event; unresolved required anchor fails while master survives |
| JSON/CSV/VTT timeline export | Redacted semantic events with validated time mapping | Identity/order preserved; output not overwritten |
| SSIM/PSNR comparison and timeline diff | Comparable source/view/duration and mechanism-specific tolerances | Blank, delayed or changed reference fails; acceptable renderer noise documented |

Preset anchors accept numeric seconds or event/offset/occurrence (`number`, `last`, `every`) with payload matching via `where`. A clip needs `start` and exactly one of `duration` or `end`; roles must be unique. A required derivative failure fails the capture but retains the master. Optional derivatives can fail with explicit warnings. Named build fields replace corresponding base launch fields; arguments do not concatenate implicitly. Custom managed workspace roots can put outputs on a qualified external volume.

These are valid released CLI patterns, **not claims that their corresponding game gates pass today**:

```sh
npm run cappy -- run <scenario> --param key=value --preset <qualified-preset> --json
npm run cappy -- record --duration 10 --json
npm run cappy -- replay <record-session-id> --no-capture --json
npm run cappy -- compare <capture-a> <capture-b> --min-ssim 0.97 --require-same-events --json
npm run cappy -- compare-builds <session-or-scenario> base <named-build> --json
npm run cappy -- timeline export <session-or-capture> --format vtt --out events.vtt
```

The 0.97 threshold is illustrative, not a global acceptance rule. Combine region/timing/audio observations where a whole-frame score hides a small broken object. Cappy owns launch/provider/media storage; the lab owns operations/simulation/replay/cameras. Preserve the released adapter's bytes rather than inventing capability behavior inside it.

### Evidence beyond a successful exit

Connect source, parameters, applied operations, events, outcomes, media and analyzer versions in one run bundle. Public indexes may expose hashes, tool versions, scenario and missing gates without revealing host paths, tokens or private composition.

| Evidence lane | Planned observations | Negative controls |
|---|---|---|
| Domain behavior | Contact, arrival, clip completion, resources, restart recovery | Disabled collision, unreachable target, missing clip, malformed save |
| Operation/replay | Applied ticks, receipts, event order, duration and state | Shifted tick, altered parameter, wrong schema/fixture/source |
| Rendering | Actual master frames, visible mechanism, ROI progression, color/viewport | Black/wrong source, frozen frame, wrong renderer, missing target |
| Encoded audio | PCM RMS, spectrum, pan, attenuation, cue onset and sync | Muted/wrong process, swapped channels, wrong tone, delayed cue |
| Capture integrity | Source identity, master probe/hash, lifecycle, timeline offset | Correct logs plus wrong window, truncated master, missing anchor |
| Export | Clean archive, actual launch, platform manifest and renderer | Missing fixture, stock template APK, wrong entry scene, absent templates |
| Performance | Warm CPU/frame percentiles, resource trends and peak working set | Leak, overload, uncapped spawn or derivative explosion |

SSIM/PSNR requires aligned frames and declared pixel/color interpretation. Retain divergent frames alongside thresholds. Audio checks inspect encoded output, not playing flags. Transcription can check authored speech against a known transcript; it adds no value to the current tone and proves no listening comfort. Godot Movie Maker and OBS are separate providers with separate evidence labels.

### Original authoring and parameter matrices

Add scripted Blender assets as an independently testable domain: typed inputs, seed, pinned Blender version, script/helper hashes, output hashes and provenance. Exercise geometry, painted atlases, vertex colors, UV tiling, material assignment, skeletal clips, collision proxies and pre-fractured pieces. Check units/axes/topology/counts/clip names and imported attributes in Godot. Generated outputs live in a scoped cache unless deliberately selected as distributable fixtures.

Reproducibility includes semantic geometry/import equivalence; binary GLB equality is a separate gate because metadata/order can differ. A generator exception returns failure with diagnostics. A static imported preview cannot prove skinning, animation or collision fidelity.

Each sweep declares typed values, seeds, renderer/host profiles, output rates, cameras, durations and maximum media count. Compute the Cartesian count before launch. Prefer boundary cases and pairwise interactions to exhaustive default combinations. Run headless semantics first, then capture representative and failing cases. Keep exact resolved invocation and hashes so one failed case can replay independently.

### Failure, cancellation and budgets

Use terminal states `succeeded`, `failed`, `cancelled`, `unavailable`, and `pending`. Separate invalid input/configuration, missing dependency, unsupported capability, timeout, assertion, provider failure and analyzer failure. Cappy's JSON envelope plus exit status is authoritative; setup success or file existence is insufficient.

Released Cappy exits are 0 for success, 1 for operation failure, 2 for usage, 3 for configuration, 4 for missing dependency, 70 for internal error and 130 for cancellation. Its JSON envelope has `ok`, `data`, `warnings` and failure `error.code`; keep the correlation ID and redacted log with failed evidence. Capture acceptance requires the actual capture state `succeeded`.

Cancellation stops accepting mutations, asks the operation to stop, flushes bounded records, stops only recording owned by the run, and releases the lab. A monotonic watchdog outside the game handles engine stalls. Keep partial masters/logs marked failed/cancelled. Never stop an unrelated OBS session. Required derivative failure preserves the original master. Cappy's ownership/hash-checked cleanup remains separate from evidence acceptance; preview destructive cleanup before performing it.

Proposed starting limits: one visible game/capture per host; 60-second ordinary scenarios; 600 simulation seconds for explicit long sessions; a 120-second short-scenario wall watchdog; eight clients; 64 KiB frames; 256 queued requests; 16 derivatives per capture; 32 sweep cases before selecting a larger budget. These are design values to qualify, not measured capacity or current enforcement. Record effective limits. Keep constrained-host analysis to short sampled frames and two FFmpeg threads until qualification supports more.

### Qualified workers and delivery

Public roles are coordinator, lightweight verifier, rendering worker, capture worker and analyzer. SSH access or an installed engine does not prove renderer, desktop/provider or free-volume availability. Probe tools/backend/free space, estimate peak intermediates, coordinate competing jobs, reserve a slot, and place output/cache/temp files on the selected volume.

Transfer identified bundles and verify hashes before analyzing transferred files. Keep private host mappings outside public metadata. Transfer establishes delivery; mechanism/media gates establish behavior. Physical input, headset comfort, speaker behavior and human preference remain deferred until physical sessions are available.

### Acceptance order

1. Typed discovery and domain dispatch; prove player/automation equivalence.
2. Bounded loopback server and shared CLI client; qualify malformed input, retries/conflicts, reconnect and cancellation.
3. MCP tools; independently prove live operations inside real Cappy freeform recording on the same run.
4. Clock profiles, seeded variants and presentation-only cameras; advertise deterministic capability only at the proved scope.
5. Blender pipelines, typed sweeps, derivatives, timelines, comparisons and resource/performance gates.
6. Additional renderer/platform/export lanes, individually qualified; preserve pending physical claims without blocking automatic work.

A broad plan must not fill the playable catalog with inert portals. Every promoted lab delivers its interaction, explanation and automated proof together.
