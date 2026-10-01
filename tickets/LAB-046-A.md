# LAB-046-A: Aim Range - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-052-B](LAB-052-B.md), [LAB-053-B](LAB-053-B.md).

Contract: [LAB-046](../experiments/LAB-046.md). Payoff: Compare ray, shape and projectile targeting with readable occlusion and collision masks.

## Acceptance

- Occluder prevents hidden target hit
- Ray/shape outcomes match documented geometry
- Mask excludes declared targets
- Hit receipt identifies stable object and position
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
