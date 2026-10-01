# LAB-047-A: Navigation Traffic - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-003-B](LAB-003-B.md), [LAB-024-B](LAB-024-B.md).

Contract: [LAB-047](../experiments/LAB-047.md). Payoff: Dispatch several agents through a bottleneck and inspect avoidance versus path planning.

## Acceptance

- Path planning still avoids static obstacle
- Bounded batch completes or reports timeout
- Avoidance changes separation trace
- Reset removes all active targets
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
