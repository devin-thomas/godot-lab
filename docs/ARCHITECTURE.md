# Architecture

## Runtime

`game/project.godot` is the independent Godot project. `game/main.tscn` boots the host. `game/main.gd` owns navigation, instructions, catalog access, and scenario dispatch; `game/world.gd` builds the playable environments; `game/player.gd` owns ordinary player movement; `game/lab_store.gd` owns scoped local progress. These are the initial boundaries, not a commitment to keep every future lab in one file.

The hub is a third-person observatory. A player can walk to a portal or choose the same lab through direct selection. Entry mounts the lab, establishes its reset baseline, and presents its controls and explanation. Leaving clears lab-owned objects and returns to the hub. Long-running lab work must be cancelled before exit.

## Shared interaction path

```text
Player input / focused UI / bounded scenario
    -> named lab operation
    -> real Godot nodes and scoped state
    -> visible feedback + diagnostic observation
    -> reset or return to hub
```

The scenario route must use real collision, rigid-body, navigation, material, audio, and file mechanisms. It may set up a known starting state or drive a target; it must not assign an expected final result to bypass the mechanism under test.

## Data and tooling

Ordinary progress belongs to `user://godot-lab/progress.json`, a versioned demo-owned file; automation uses `user://godot-lab/automation-progress.json`. Schema 1 stores earned lab IDs, reduced-motion and mute preferences. The runtime rejects malformed/version-invalid data and preserves it until an explicit checkpoint save. Room reset rebuilds geometry while preserving earned seals. Credentials, analytics, and cloud synchronization are outside the baseline.

`scripts/check.py` orchestrates automated checks. `scripts/build.py` handles export. Optional Node tooling integrates the official Cappy npm package. Build, source execution, encoded Godot movie output, Cappy provider capture, and exported-executable launch are recorded separately.

## Renderer and resources

The first release uses Godot 4.7.2 Compatibility rendering; the exact tested engine/renderer belongs in BUILD_STATUS. A future experiment may require another renderer, but must expose that gate and preserve access to the baseline hub. Scene-owned resources are freed on exit; original fixtures are bounded, reusable, and documented.
