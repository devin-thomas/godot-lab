# Architecture decisions

## ADR-001: Playable product with inspectable evidence

Accepted 2026-10-01. Ordinary play is the primary interface. Automated replay and video are secondary inspection paths. Consequence: each lab needs controls, reset, and exit even when a script can exercise it.

## ADR-002: Independent public core

Accepted 2026-10-01. The public checkout contains everything needed for the account-free baseline. Capture tooling is optional. Consequence: no restricted assets, unpublished research copies, credentials, or environment paths enter the runtime or public history.

## ADR-003: Six-lab bootstrap (scope superseded by ADR-007)

Accepted for the initial bootstrap, 2026-10-01. Collision, rigid bodies, navigation, materials, spatial audio and persistence established a bounded playable/tested route. Treating this as sufficient product scope is superseded by ADR-007. Historical evidence remains valid for bounded mechanisms; future capabilities do not receive playable badges.

## ADR-004: Authored retro identity with clean presentation

Accepted 2026-10-01. Use low-poly silhouettes, pixel-authored textures, broad shade shapes, and restrained fog. Default camera and controls remain smooth. Consequence: CRT, shake, flashing, and geometry wobble are optional experiments, never prerequisites for understanding a lab.

## ADR-005: Evidence states by mechanism

Accepted 2026-10-01. Headless simulation, rendered output, encoded audio, Cappy/OBS provider capture, export launch, and human/device use establish different claims. Consequence: a passing state test cannot close an appearance, audibility, or hardware gate.

## ADR-006: Repeatable scenarios with simulation tolerances

Accepted 2026-10-01. Reset fixtures, bounded action sequences, and stable semantic IDs define scenarios. Physics checks use outcomes/tolerances rather than portable bit-identical snapshots. Consequence: reports record engine, platform, renderer, seed, and scenario version.

## ADR-007: Comprehensive program and explicit depth

Accepted 2026-10-01 following the user's scope correction. Plan 96 detailed labs in 16 wings, shared engine/automation systems, composed journeys and dependency-ordered implementation/qualification. Six rooms are M0, not the full product. Consequence: retain bootstrap proof, specify future depth honestly, and make the plan machine-checkable rather than adding only catalog names.

## ADR-008: One operation spine, independent presentation

Accepted for expansion. UI, scenarios, CLI, authenticated live API and MCP route through typed operations; fixed-tick simulation and viewer tracks have separate records. Cappy and live control must coexist in one session. Consequence: protocol, provider and movie evidence have distinct gates; new operation names remain proposals until implemented.

## ADR-009: Optional profiles and reusable modules

Accepted for expansion. Static registration, injected services, independently probed adapters and extraction scenes replace monolithic growth. Consequence: advanced rendering, editor/native, providers, networking, mobile and XR do not break the default account-free game.

## ADR-010: Original authoring and source-bound production

Accepted for expansion. Scripted assets, rig/clip/material import, capture, workers and analysis carry source/fixture/recipe identity, budgets and cancellation. Consequence: art is a system under test; private reference material and worker routes remain private.
