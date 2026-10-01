# Build status

Evidence snapshot: 2026-10-01, foundation runtime `2ca31ff17979971f694807e23184df8264f2c50d`. This is a runnable six-lab build with automatic verification. Subsequent source maintenance preserves the official adapter's exact npm bytes and records delivery evidence. No human playtesting, physical controller qualification, or other-platform claim is made.

## Toolchain and artifact

Tested engine: `4.7.2.stable.official.ed1daf0bf` with Compatibility rendering, 60 Hz physics, and a 1280 x 720 viewport. The Windows Desktop export creates the unsigned local `dist/GodotLab.exe`. Generated exports and raw evidence are ignored rather than committed.

The latest `python scripts/check.py --render --export` run passed 23 outcome checks in each headless, windowed-rendered, and Windows-exported route. Each route also passed a fresh-process restart that recovered all six seals. This establishes the foundation on the tested Windows host; publication and an independent clean-source check receive their own ledger entry.

| Gate | Recorded result | Evidence |
|---|---|---|
| Godot import and first-party script loading | Passed | `scripts/check.py`, `game/tests/load_scripts.gd` |
| Parser negative control | Passed | Checker deliberately rejected a temporary malformed script |
| Headless integration | 23 checks passed | `artifacts/headless.json` |
| Fresh-process persistence | Six seals recovered | `artifacts/headless-restart.json` |
| Windowed rendered integration | 23 checks and fresh-process restart passed | `artifacts/rendered.json`, `artifacts/rendered-restart.json`, `artifacts/screens/` |
| Windows exported-executable smoke | 23 checks and fresh-process restart passed | `artifacts/exported.json`, `artifacts/exported-restart.json`, `artifacts/build.json` |
| Keyboard dispatch and solid collision | Passed in expanded headless route | Named checks in `artifacts/headless.json` |
| Controller synthetic action | Passed; no physical controller test | Named check in `artifacts/headless.json` |
| Official Cappy discovery/input replay | Passed; semantic replay, not bit-identical physics | `.artifacts/cappy-gate.json` |
| Cappy/OBS all six scenarios | Recorded game-only pixels and successful LAB_PROOF events | `.artifacts/capture-<id>.json` and extracted frames |
| Encoded spatial audio | Passed non-silence, near/far attenuation, stereo dominance swap, and 220 Hz tone | `.artifacts/cappy-audio-gate.json`, `.artifacts/capture-audio.wav` |
| Public-only source archive | 23 checks and fresh-process restart passed with no sibling dependencies | `artifacts/public-source.json`; `python scripts/source_gate.py` |
| Public distribution review | Passed source allowlist, license/provenance and ignored-artifact checks | Original project assets; exact released adapter with MIT license; generated captures, credentials and executable excluded from Git |
| Human comfort and real controller | Deferred by requested scope | Requires later human/input session |
| Other platforms and physical devices | Deferred by requested scope | Requires platform-specific evidence |

Reports are local generated evidence locations, not public downloadable links. Earlier failed development reports are not passing proof. Public source is delivered through the canonical repository's `main` branch; generated unsigned binaries remain local. The private composition is unnecessary to play, build or verify the public source.

## What the checks establish

The motion route moves, jumps, lands, and is blocked by real collision geometry. Physics applies an impulse and checks the body's displacement/settling. Navigation dispatches an agent along a non-straight path to the fixed target. Materials cycles the left sample while keeping middle/right references stable. Audio checks source state plus actual encoded tone, attenuation, and stereo change. Persistence checks real files, invalid/truncated schema, unknown labs, preservation of invalid input, and a fresh-process restart. Every room has a reset check; room reset preserves earned progress.

Cappy is the official `@uppercut-labs/cappy@0.1.0` npm package. Scenario discovery and a four-second input recording/replay matched semantic actions and material state; that test reports `captureVerified: false` because capture is a separate operation. Provider runs use OBS 32.2.2 and game-window-only 1280 x 720 video. FFmpeg sampling rejects black/flat output and saves an actual frame. Passing pixels and LAB_PROOF support the bounded scenario, not human usability or comprehensive visual quality.

The audio fixture is an original precomputed, natively looped 220 Hz mono tone in AudioStreamPlayer3D. The actual OBS game-process-only recording was decoded to 24 kHz stereo. Its near RMS was approximately 0.02686 per channel, versus far RMS 0.00122/0.00072; left/right phase channel dominance swapped by about 2:1, and the dominant authored frequency was 220 Hz. This proves the encoded artifact's spatial response, not physical speaker/headphone behavior.

## Reproduce

From the repository root, make the tested console engine available through `GODOT` or the command path. Python tooling uses only the standard library. Matching Godot export templates are needed to build the executable.

```powershell
godot --path game
python scripts/check.py --render --export
python scripts/build.py
.\dist\GodotLab.exe
```

The checker also accepts `--godot <console-executable>`. To run only the bounded assertion route, use `godot --headless --path game -- --verify --report=<absolute-report-path>`. `--tour` runs the presentation route. See AUTOMATION for the optional npm/provider workflow.

## Controls and stored data

WASD or arrow keys move; Space jumps; E enters a nearby station or performs its operation; R rebuilds the active room; Escape returns to the hub; 1-6 selects a lab directly. Catalog buttons support keyboard focus. Controller left-stick and action mappings exist and a synthetic action was checked; real device behavior remains untested. CALM reduces character bobbing, MUTE controls the master bus, and optional CRT scanlines begin disabled.

Ordinary progress belongs to `user://godot-lab/progress.json` (schema 1): earned lab IDs, CALM, and MUTE. Automation uses `user://godot-lab/automation-progress.json` so scenario runs do not alter ordinary progress. The demo stores no account or analytics data. Persistence is a checkpoint/seal example, not arbitrary-position restoration or a general save-slot system.
