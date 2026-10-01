# LAB-059-A: LOD Walk - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-012](CORE-012.md), [CORE-018](CORE-018.md), [LAB-017-B](LAB-017-B.md), [LAB-036-B](LAB-036-B.md), [LAB-011-B](LAB-011-B.md).

Contract: [LAB-059](../experiments/LAB-059.md). Payoff: Walk an identical camera route and inspect mesh detail transitions, culling and visual discontinuity.

## Acceptance

- LOD threshold matches declared distance
- Visible object IDs stay semantically stable
- Culling preserves required landmarks
- Timing/triangle metrics tied to renderer
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
