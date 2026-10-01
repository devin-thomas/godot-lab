# Godot Lab

**Walk into the engine. Try a capability. Inspect its mechanism. Replay its proof.**

Godot Lab is a playable capability museum: an original retro 3D hub connects small experiments in movement, simulation, rendering, sound, and durable state. Each experiment has a physical interaction, an explanation, a reset path, and an automated scenario. A recording is evidence of a playable system; the executable is the product.

The first playable build contains six labs: **Motion atelier**, **Gravity foundry**, **Pathfinder garden**, **Paint & light**, **Signal chamber**, and **Memory archive**. The broader [capability catalog](experiments/INDEX.md) describes future work without presenting it as shipped. Current checks and remaining gates belong in [BUILD_STATUS](docs/BUILD_STATUS.md).

## Play and verify

The local Windows export is `dist/GodotLab.exe`. From the repository root:

```powershell
.\dist\GodotLab.exe
godot --path game
python scripts/check.py --render --export
```

The source/check routes require Godot 4.7.2 stable and matching export templates; set `GODOT` to its console executable or pass `--godot` to the checker. Build with `python scripts/build.py`. The executable is a generated, unsigned local artifact rather than a file committed to this repository. WASD/arrows move, Space jumps, E interacts, R resets the room, Escape returns to the hub, and 1-6 selects a lab.

## Begin

Read [START_HERE](START_HERE.md) to play or build. [SPEC](SPEC.md) defines the product, [ART_DIRECTION](docs/ART_DIRECTION.md) defines its look, and [TEST_STRATEGY](docs/TEST_STRATEGY.md) explains what the evidence can establish. Builders follow [AGENTS](AGENTS.md), [CONTRIBUTING](CONTRIBUTING.md), and the [ticket board](tickets/README.md).

The public project runs with original bundled examples and local storage. No account, API key, OBS installation, recording session, or network service is required to play. Capture tools are optional developer tooling. Cappy's official npm package supplies the capture integration; see [AUTOMATION](docs/AUTOMATION.md) for its verified contract and limits.

## Repository map

| Area | What it communicates |
|---|---|
| [Context.md](Context.md) | Why an interactive engine laboratory exists |
| [SPEC.md](SPEC.md) | Scope, behavior, milestones, and completion rules |
| [experiments/INDEX.md](experiments/INDEX.md) | Six first-release labs and specified expansion opportunities |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Host, lab boundaries, and operation flow |
| [docs/EXTENSION_CONTRACT.md](docs/EXTENSION_CONTRACT.md) | Requirements for a new playable lab |
| [docs/ART_DIRECTION.md](docs/ART_DIRECTION.md) | Original palette, geometry, texture, UI, and comfort rules |
| [docs/AUTOMATION.md](docs/AUTOMATION.md) | Scenario replay, Cappy recording, and analysis |
| [docs/BUILD_STATUS.md](docs/BUILD_STATUS.md) | Actual build and verification evidence |
| [docs/SOURCE_INDEX.md](docs/SOURCE_INDEX.md) | Public source references and research confidence |
| [ADR.md](ADR.md) | Decisions and consequences |

Project code and original project material are MIT licensed. Third-party engine, fonts, tooling, and independently supplied assets retain their own licenses; see [ASSET_POLICY](docs/ASSET_POLICY.md). This independent project is not sponsored by Godot or by the games discussed as visual references.
