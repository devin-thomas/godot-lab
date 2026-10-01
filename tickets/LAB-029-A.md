# LAB-029-A: Streaming Depot - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-006-B](LAB-006-B.md), [LAB-028-B](LAB-028-B.md).

Contract: [LAB-029](../experiments/LAB-029.md). Payoff: Walk across scene boundaries while loading chunks and preserving local changes.

## Acceptance

- Boundary activates requested chunk
- Changed object returns with correct state
- Cancelled load never mounts late
- Resident chunk cap holds
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
