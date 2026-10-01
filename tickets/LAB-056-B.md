# LAB-056-B: Voxel Quarry - Qualification

State: specified. Planned wave: M3 (future lab).
Depends on: [LAB-056-A](LAB-056-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-056](../experiments/LAB-056.md). Payoff: Edit a tiny voxel volume and inspect meshing, collision and chunk seams.

## Acceptance

- Edit changes expected cells only
- Boundary surfaces have no cracks
- Collision follows committed mesh
- Same voxel data gives same topology signature
- Out-of-bounds edit rejects
- Cancelled rebuild cannot replace last complete chunk
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
