# LAB-007-A: Tile Workshop - Implementation/deepening

State: specified. Planned wave: M1 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-001-B](LAB-001-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-007](../experiments/LAB-007.md). Payoff: Paint a playable 2D room and see terrain seams and collision update together.

## Acceptance

- Same edit sequence produces same cell IDs
- Collision matches solid tiles
- Undo restores all changed cells
- Terrain seams use expected neighbors
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
