# Architecture decisions

## ADR-001: Playable product with inspectable evidence

Accepted 2026-10-01. Ordinary play is the primary interface. Automated replay and video are secondary inspection paths. Consequence: each lab needs controls, reset, and exit even when a script can exercise it.

## ADR-002: Independent public core

Accepted 2026-10-01. The public checkout contains everything needed for the account-free baseline. Capture tooling is optional. Consequence: no restricted assets, unpublished research copies, credentials, or environment paths enter the runtime or public history.

## ADR-003: Six meaningful labs before catalog breadth

Accepted 2026-10-01. Ship collision, rigid bodies, navigation, materials, spatial audio, and persistence as the first coherent route. Consequence: future capabilities remain explicitly specified and do not receive playable badges.

## ADR-004: Authored retro identity with clean presentation

Accepted 2026-10-01. Use low-poly silhouettes, pixel-authored textures, broad shade shapes, and restrained fog. Default camera and controls remain smooth. Consequence: CRT, shake, flashing, and geometry wobble are optional experiments, never prerequisites for understanding a lab.

## ADR-005: Evidence states by mechanism

Accepted 2026-10-01. Headless simulation, rendered output, encoded audio, Cappy/OBS provider capture, export launch, and human/device use establish different claims. Consequence: a passing state test cannot close an appearance, audibility, or hardware gate.

## ADR-006: Repeatable scenarios with simulation tolerances

Accepted 2026-10-01. Reset fixtures, bounded action sequences, and stable semantic IDs define scenarios. Physics checks use outcomes/tolerances rather than portable bit-identical snapshots. Consequence: reports record engine, platform, renderer, seed, and scenario version.
