# LAB-007-B: Tile Workshop - Qualification

State: specified. Planned wave: M1 (future lab).
Depends on: [LAB-007-A](LAB-007-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-007](../experiments/LAB-007.md). Payoff: Paint a playable 2D room and see terrain seams and collision update together.

## Acceptance

- Same edit sequence produces same cell IDs
- Collision matches solid tiles
- Undo restores all changed cells
- Terrain seams use expected neighbors
- Invalid tile ID rejects before mutation
- Out-of-bounds stroke refuses or clips according to documented policy
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
