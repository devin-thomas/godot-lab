# LAB-016-A: Terrain Foundry - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-001-B](LAB-001-B.md), [LAB-035-B](LAB-035-B.md).

Contract: [LAB-016](../experiments/LAB-016.md). Payoff: Sculpt or import terrain and compare visual form, collision and level-of-detail boundaries.

## Acceptance

- Mesh height follows samples
- Collision matches edited surface within tolerance
- Patch seam stays closed
- Undo restores original samples
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
