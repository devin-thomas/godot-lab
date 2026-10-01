# Start here

For the expanded program, read [SPEC](SPEC.md), [the 96-lab catalog](experiments/INDEX.md), [MILESTONES](docs/MILESTONES.md), [ROADMAP](docs/ROADMAP.md), [profiles](docs/CAPABILITY_PROFILES.md), and [journeys](docs/JOURNEYS.md). The six-room executable is M0. Begin future implementation with shared-system tickets. Validate consistency with `python scripts/plan.py --check --self-test`.

## Play

Use the run and export commands in [BUILD_STATUS](docs/BUILD_STATUS.md); that page names the actual engine and files tested for the current build. Begin in the hub, walk to a labeled station, and interact. The station explains what to try, what the engine is doing, and how to reset or return. You can visit the six first-release labs in any order.

The intended route is collision -> impulse -> navigation -> materials -> sound -> persistence. Compare a direct player action with the same repeatable automation scenario. Watching a movie alone cannot establish that the lab is usable with ordinary input.

## Build

1. Read [SPEC](SPEC.md), [AGENTS](AGENTS.md), and [architecture](docs/ARCHITECTURE.md).
2. Confirm the toolchain and the real command contract in [BUILD_STATUS](docs/BUILD_STATUS.md).
3. Run the automated checks before changing behavior. Record failures without converting them into passing fallback results.
4. Use [the extension contract](docs/EXTENSION_CONTRACT.md) and [lab template](experiments/TEMPLATE.md) to add an experiment.
5. Pair the playable route with a bounded replay scenario and state assertions. Add rendered and audio checks where the claim requires them.

## Read the evidence

`implemented` means the interaction exists. `automated-verified` means the named automated checks passed for a recorded build and machine. `human-verified` needs an actual human session. `release-ready` additionally needs an exported executable check and distribution review. These are separate claims, and none implies another platform was tested.

No human or physical-device acceptance is required to finish the current automated delivery. Those gates remain visible for later testing rather than delaying the first executable.
