# LAB-057-A: Navmesh Workshop - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-003-B](LAB-003-B.md), [LAB-028-B](LAB-028-B.md).

Contract: [LAB-057](../experiments/LAB-057.md). Payoff: Move an obstacle and inspect the difference between navigation rebake and runtime avoidance.

## Acceptance

- New committed path avoids moved obstacle
- Path switches only after map sync
- Failed bake preserves previous region
- Reset restores baseline path
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, editor, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
