# LAB-022-A: Destruction Cell - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-002-B](LAB-002-B.md), [LAB-049-B](LAB-049-B.md).

Contract: [LAB-022](../experiments/LAB-022.md). Payoff: Break an original assembly into bounded physical fragments and rebuild it.

## Acceptance

- Only threshold-crossed joints detach
- Fragment count remains capped
- Detached pieces collide/settle
- Reset restores all connections
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
