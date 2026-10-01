# Build status

## Parallel implementation wave

2026-10-01, Windows, Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility. Runtime source `cc01fc46915fb75923519c94a366317a701203f8` adds 35 playable prototypes to the six original rooms: **41 playable routes** with a searchable 96-contract catalog, parameter controls, a live inspector and reusable operation/storage/evidence foundations. [Implementation waves](IMPLEMENTATION_WAVES.md) identifies actual mechanisms and extraction paths. Full A/B contracts and composed journeys remain open.

The logic wave passed 51 foundation checks (typed operations, stale revision/epoch, retry identity, bounded records and evidence declarations), 45 storage/job/fixture/capability checks, 251 independent system-module checks, 177 visual headless checks (two renderer readbacks explicitly unavailable), 180 Compatibility-rendered mechanism checks, 47 host boundary checks, 185 independent data-module checks, and **386 host scenario/lifecycle/negative checks across 35 prototypes**. The optional live HTTP/CLI/stdio MCP route passed 32 actual child-process checks plus 12 client unit tests. Cappy harness boundary tests passed seven checks. Source fingerprint regeneration/check is `python game/labs/data/update_fingerprint.py --check`; Git archives and the new fingerprinted scripts use LF.

All 35 prototype scenarios passed their 386 checks in headless, Compatibility-rendered and actual exported Windows-executable routes. The six original rooms passed 23 outcome checks and fresh-process persistence in all three routes. The windowed wave captured and inspected all 35 prototype views, including the repaired terrain mesh and visible data controls. Reports are `artifacts/modules-{headless,rendered,exported}.json`, `wave-logic.json`, `prototype-screens/`, and original-room reports below. The actual export is unsigned `dist/GodotLab-0.2.0.exe`; its generated hash/size are in `artifacts/build.json`.

Run `python scripts/check.py --render --export` for the integrated wave. Rendered review found reversed terrain triangles that headless physics could not detect; winding and authored height colors were repaired and checked again. The worker scenario now polls actual completion under a bounded deadline; cancellation discards uncommitted results even if already finished. Retry checks preserve actual job identity, revision and committed state while allowing ongoing worker progress. These prototypes do not complete full media/provider/device contracts. Historical six-room recordings remain historical evidence.

## Expanded Cappy provider wave

The released `@uppercut-labs/cappy@0.1.0` adapter discovered **41 scenarios** at build 0.2.0. A four-second freeform session remained replayable on the original six-room route and rejected prototype entry with an explicit `input-v1` scope error. The optional HTTP inspector observed the same owned process during discovery and both selected named captures. This proves local coexistence; it does not qualify every CLI/MCP operation inside a recording.

Both actual OBS 32.2.2 game-only captures succeeded against clean runtime commit `cc01fc46915fb75923519c94a366317a701203f8`, game input-set hash `0c39f81f506d1cdeb392243c33fa528726d50300632e730ff772c346946ba3d3`:

| Scenario | Capture | Actual master | State/media checks |
|---|---|---|---|
| LAB-013 UI Workshop | `cap_5f3c5368-df16-41e3-bca4-ab2a4040dd6c` | 1280 x 720, 4.466 s, SHA-256 `e152c131c14b358983c023976ec505b5df47829f4d3d2f3783d2c3ccbc62c8b9` | Six LAB_PROOF assertions, 77 same-process HTTP samples, 18 decoded frames |
| LAB-007 Tile Workshop | `cap_9966c06f-07ef-482d-a2ea-caae837d7c29` | 1280 x 720, 4.566 s, SHA-256 `3d350e408a195e8c3711939bd947a3394067252922e055335c9a6abde411f9b2` | Six LAB_PROOF assertions, 78 same-process HTTP samples, 18 decoded frames |

Decoded samples were inspected for the correct lab/view/state and nonblack, changing frames. The Tile Workshop's full interactive canvas is below its controls in the scrollable workbench; these selected frames do not establish every painted cell's visibility or general usability. Reports and sampled images are local in `.artifacts/cappy-prototypes.json` and `.artifacts/cappy-prototype-LAB-*-frame.png`; actual masters remain managed by Cappy. Source hashes stayed fixed during both recordings. These two bounded provider checks do not qualify all 35 prototypes, audio, physical input or human comfort. Historical original-six encoded audio proof is retained below.

## Expanded planning delivery

Planning snapshot: 2026-10-01. The program specifies **96 labs in 16 wings**, **17 shared-system tickets**, **192 laboratory implementation/qualification tickets**, **eight public journeys**, and six milestone waves. The private repository specifies twelve composed experiences with its own 39-ticket graph. All expanded A/B contracts remain open; narrower implemented prototypes are recorded separately above. Generated planning pages do not upgrade runtime evidence.

`python scripts/plan.py --check --self-test` passed catalog identity/depth/evidence validation, both dependency graphs, milestone prerequisites, eight journey contracts, 308 generated-document coherence checks, local-link resolution and 12 deliberate invalid-planning controls, including omitted first-six depth qualification. The public archive gate repeats those checks independently before the existing runtime assertions. These checks qualify planning source, not future gameplay.

The historical foundation runtime/source revision is `ad7d305f4f8057296cf75cacd6624c6d329bf236`. Its six-room media proof follows below. Later implementation waves retain that provenance and record their own source/render/export/capture boundaries above.

## Bootstrap runtime evidence

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
.\dist\GodotLab-0.2.0.exe
```

The checker also accepts `--godot <console-executable>`. To run only the bounded assertion route, use `godot --headless --path game -- --verify --report=<absolute-report-path>`. `--tour` runs the presentation route. See AUTOMATION for the optional npm/provider workflow.

## Controls and stored data

WASD or arrow keys move; Space jumps; E enters a nearby station or performs its operation; R rebuilds the active room; Escape returns to the hub; 1-6 selects a lab directly. Catalog buttons support keyboard focus. Controller left-stick and action mappings exist and a synthetic action was checked; real device behavior remains untested. CALM reduces character bobbing, MUTE controls the master bus, and optional CRT scanlines begin disabled.

Ordinary progress belongs to `user://godot-lab/progress.json` (schema 1): earned lab IDs, CALM, and MUTE. Automation uses `user://godot-lab/automation-progress.json` so scenario runs do not alter ordinary progress. The demo stores no account or analytics data. Persistence is a checkpoint/seal example, not arbitrary-position restoration or a general save-slot system.
