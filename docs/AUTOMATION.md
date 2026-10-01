# Scenario and capture automation

Godot Lab exposes bounded verification and a repeatable presentation tour. These operate the playable systems. Capturing them produces evidence and reusable media without changing the product into a movie-only showcase. Physics scenarios explicitly report that they are not deterministic across hosts.

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

1. Probe the named provider and package version; record unavailable status explicitly.
2. Reset the lab; establish its source, camera, resolution, and bounded route.
3. Start recording, run the real scenario, and stop recording even on failure.
4. Inspect output existence, duration, resolution, frame progression, visible mechanism, and encoded audio where required.
5. Attach the state report and capture result to the same scenario/build identity.

Developer capture is an explicit local action, not automatic recording of a player's session. The game remains playable without Cappy, Node, FFmpeg, OBS, or network access.
