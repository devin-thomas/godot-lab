# LAB-017-A: Crowd Balcony - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-012](CORE-012.md), [CORE-018](CORE-018.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-017](../experiments/LAB-017.md). Payoff: Compare individual meshes and instancing under the same crowd layout and camera.

## Acceptance

- Both modes show same declared count
- Transform distribution matches seed
- Profiler records actual draw/time metrics
- Reset releases allocated crowd
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
