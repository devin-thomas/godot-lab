# LAB-016-B: Terrain Foundry - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-016-A](LAB-016-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-016](../experiments/LAB-016.md). Payoff: Sculpt or import terrain and compare visual form, collision and level-of-detail boundaries.

## Acceptance

- Mesh height follows samples
- Collision matches edited surface within tolerance
- Patch seam stays closed
- Undo restores original samples
- Invalid dimensions reject
- Cancelled rebuild preserves previous complete patch
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
