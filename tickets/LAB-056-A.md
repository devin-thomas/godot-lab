# LAB-056-A: Voxel Quarry - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-016-B](LAB-016-B.md), [LAB-028-B](LAB-028-B.md), [LAB-029-B](LAB-029-B.md).

Contract: [LAB-056](../experiments/LAB-056.md). Payoff: Edit a tiny voxel volume and inspect meshing, collision and chunk seams.

## Acceptance

- Edit changes expected cells only
- Boundary surfaces have no cracks
- Collision follows committed mesh
- Same voxel data gives same topology signature
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
